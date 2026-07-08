const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();
const db = admin.firestore();

// ---------------------------------------------------------------------------
// Helper: verify caller is an admin (checked against /admins/{uid} collection)
// ---------------------------------------------------------------------------
async function assertIsAdmin(context) {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Waa inaad gashaa.");
  }
  const doc = await db.collection("admins").doc(context.auth.uid).get();
  if (!doc.exists) {
    throw new functions.https.HttpsError("permission-denied", "Ma lihid awood admin.");
  }
}

// ---------------------------------------------------------------------------
// SUBSCRIPTION PRICE (admin can change it any time, default $0.60)
// ---------------------------------------------------------------------------
exports.getSubscriptionPrice = functions.https.onCall(async (data, context) => {
  const doc = await db.collection("config").doc("subscription").get();
  const priceUsd = doc.exists ? doc.data().priceUsd : 0.60;
  return { priceUsd };
});

exports.changeSubscriptionPrice = functions.https.onCall(async (data, context) => {
  await assertIsAdmin(context);
  const { priceUsd } = data;
  if (typeof priceUsd !== "number" || priceUsd <= 0) {
    throw new functions.https.HttpsError("invalid-argument", "Qiimo sax ah geli.");
  }
  await db.collection("config").doc("subscription").set({ priceUsd }, { merge: true });
  return { success: true, priceUsd };
});

// ---------------------------------------------------------------------------
// EVC PLUS (Hormuud) PAYMENT
// Replace HORMUUD_API_URL / MERCHANT credentials with your real merchant
// account details, stored securely via `firebase functions:config:set`.
// ---------------------------------------------------------------------------
exports.createEvcPlusPayment = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Waa inaad gashaa.");
  }
  const { phoneNumber, amountUsd } = data;
  if (!phoneNumber || !amountUsd) {
    throw new functions.https.HttpsError("invalid-argument", "Lambarka & qiimaha waa loo baahan yahay.");
  }

  const merchantConfig = functions.config().hormuud || {};
  if (!merchantConfig.merchant_uid || !merchantConfig.api_key) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "EVC Plus merchant account lama qeexin. Fadlan isticmaal `firebase functions:config:set hormuud.merchant_uid=... hormuud.api_key=...`"
    );
  }

  const paymentRef = db.collection("payments").doc();
  await paymentRef.set({
    uid: context.auth.uid,
    method: "evc_plus",
    phoneNumber,
    amountUsd,
    status: "pending",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  try {
    // Example call shape only — replace URL/payload with your merchant's actual API docs.
    const response = await axios.post(
      merchantConfig.api_url || "https://api.waafipay.net/asm",
      {
        schemaVersion: "1.0",
        requestId: paymentRef.id,
        timestamp: Date.now(),
        channelName: "WEB",
        serviceName: "API_PURCHASE",
        serviceParams: {
          merchantUid: merchantConfig.merchant_uid,
          apiUserId: merchantConfig.api_user_id,
          apiKey: merchantConfig.api_key,
          paymentMethod: "mwallet_account",
          payerInfo: { accountNo: phoneNumber },
          transactionInfo: {
            referenceId: paymentRef.id,
            invoiceId: paymentRef.id,
            amount: amountUsd,
            currency: "USD",
            description: "SportLiveTV Premium Subscription",
          },
        },
      }
    );

    await paymentRef.update({ providerResponse: response.data });
    return { success: true, message: "Fadlan xaqiiji lacag-bixinta SMS-kaaga.", paymentId: paymentRef.id };
  } catch (err) {
    await paymentRef.update({ status: "failed", error: err.message });
    throw new functions.https.HttpsError("internal", "EVC Plus payment waa fashilantay.");
  }
});

// ---------------------------------------------------------------------------
// USDT (TRC20) PAYMENT
// In production, generate a unique deposit address per user (via your wallet
// provider e.g. TronGrid/BitGo) or use a fixed address + memo-based tracking,
// then confirm via a blockchain webhook (see confirmUsdtWebhook below).
// ---------------------------------------------------------------------------
exports.createUsdtPaymentIntent = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Waa inaad gashaa.");
  }
  const { uid, amountUsd } = data;
  const walletConfig = functions.config().usdt || {};
  if (!walletConfig.deposit_address) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "USDT wallet lama qeexin. Isticmaal `firebase functions:config:set usdt.deposit_address=...`"
    );
  }

  const paymentRef = db.collection("payments").doc();
  await paymentRef.set({
    uid,
    method: "usdt_trc20",
    amountUsd,
    status: "pending",
    depositAddress: walletConfig.deposit_address,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return {
    success: true,
    paymentId: paymentRef.id,
    depositAddress: walletConfig.deposit_address,
  };
});

/**
 * Webhook to be called by your USDT payment processor / blockchain listener
 * once a matching on-chain transaction is confirmed. Activates premium.
 */
exports.confirmUsdtWebhook = functions.https.onRequest(async (req, res) => {
  const secret = req.headers["x-webhook-secret"];
  if (secret !== functions.config().usdt.webhook_secret) {
    return res.status(401).send("Unauthorized");
  }
  const { paymentId, txHash, confirmed } = req.body;
  if (!confirmed) return res.status(200).send("Ignored - not confirmed");

  const paymentRef = db.collection("payments").doc(paymentId);
  const payment = await paymentRef.get();
  if (!payment.exists) return res.status(404).send("Payment not found");

  await paymentRef.update({ status: "confirmed", txHash });
  await activatePremium(payment.data().uid);
  return res.status(200).send("OK");
});

async function activatePremium(uid) {
  const expires = new Date();
  expires.setMonth(expires.getMonth() + 1);
  await db.collection("users").doc(uid).update({
    isPremium: true,
    premiumExpiresAt: expires.toISOString(),
  });
}

exports.checkPremiumStatus = functions.https.onCall(async (data, context) => {
  const { uid } = data;
  const userDoc = await db.collection("users").doc(uid).get();
  if (!userDoc.exists) return { isPremium: false };
  const u = userDoc.data();
  const isPremium = u.isPremium && (!u.premiumExpiresAt || new Date(u.premiumExpiresAt) > new Date());
  return { isPremium };
});

// ---------------------------------------------------------------------------
// SCHEDULED: expire premium subscriptions automatically once a month is up
// ---------------------------------------------------------------------------
exports.expirePremiumSubscriptions = functions.pubsub
  .schedule("every 24 hours")
  .onRun(async () => {
    const now = new Date().toISOString();
    const expired = await db
      .collection("users")
      .where("isPremium", "==", true)
      .where("premiumExpiresAt", "<", now)
      .get();

    const batch = db.batch();
    expired.forEach((doc) => batch.update(doc.ref, { isPremium: false }));
    await batch.commit();
    return null;
  });

// ---------------------------------------------------------------------------
// ADMIN: manage users (block/unblock, activate/deactivate premium manually)
// ---------------------------------------------------------------------------
exports.adminSetUserBlocked = functions.https.onCall(async (data, context) => {
  await assertIsAdmin(context);
  const { targetUid, blocked } = data;
  await db.collection("users").doc(targetUid).update({ isBlocked: blocked });
  if (blocked) {
    await admin.auth().updateUser(targetUid, { disabled: true });
  } else {
    await admin.auth().updateUser(targetUid, { disabled: false });
  }
  return { success: true };
});

exports.adminSetPremium = functions.https.onCall(async (data, context) => {
  await assertIsAdmin(context);
  const { targetUid, isPremium, days } = data;
  const update = { isPremium };
  if (isPremium) {
    const expires = new Date();
    expires.setDate(expires.getDate() + (days || 30));
    update.premiumExpiresAt = expires.toISOString();
  }
  await db.collection("users").doc(targetUid).update(update);
  return { success: true };
});

// ---------------------------------------------------------------------------
// ADMIN: broadcast push notification to all users (via FCM topic "all_users")
// Client apps should subscribe to topic "all_users" on startup.
// ---------------------------------------------------------------------------
exports.adminBroadcastNotification = functions.https.onCall(async (data, context) => {
  await assertIsAdmin(context);
  const { title, body } = data;
  await admin.messaging().send({
    topic: "all_users",
    notification: { title, body },
  });
  return { success: true };
});

// ---------------------------------------------------------------------------
// SCHEDULED: send kickoff reminder 15 minutes before a match starts
// ---------------------------------------------------------------------------
exports.matchKickoffReminders = functions.pubsub
  .schedule("every 5 minutes")
  .onRun(async () => {
    const now = new Date();
    const soon = new Date(now.getTime() + 15 * 60 * 1000);
    const matches = await db
      .collection("matches")
      .where("startTime", ">=", now.toISOString())
      .where("startTime", "<=", soon.toISOString())
      .where("reminderSent", "==", false)
      .get();

    for (const doc of matches.docs) {
      const m = doc.data();
      await admin.messaging().send({
        topic: `match_${doc.id}`,
        notification: {
          title: "Ciyaartu waa dhawaan bilaabmi",
          body: `${m.teamAName} vs ${m.teamBName} - 15 daqiiqo kadib`,
        },
      });
      await doc.ref.update({ reminderSent: true });
    }
    return null;
  });

// ---------------------------------------------------------------------------
// ADMIN: revenue & user statistics for dashboard
// ---------------------------------------------------------------------------
exports.adminGetStats = functions.https.onCall(async (data, context) => {
  await assertIsAdmin(context);

  const usersSnap = await db.collection("users").get();
  const totalUsers = usersSnap.size;
  const premiumUsers = usersSnap.docs.filter((d) => d.data().isPremium).length;
  const blockedUsers = usersSnap.docs.filter((d) => d.data().isBlocked).length;

  const paymentsSnap = await db.collection("payments").where("status", "in", ["confirmed", "success"]).get();
  let totalRevenue = 0;
  paymentsSnap.forEach((d) => (totalRevenue += d.data().amountUsd || 0));

  return {
    totalUsers,
    premiumUsers,
    blockedUsers,
    totalRevenue,
  };
});
