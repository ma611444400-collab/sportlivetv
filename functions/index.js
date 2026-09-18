const { onRequest } = require("firebase-functions/v2/https");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();
const db = admin.firestore();

// Configure this only in the deployed runtime; never commit the provider key.
const API_KEY = process.env.API_FOOTBALL_KEY || "";
const API_HOST = "v3.football.api-sports.io";

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

function assertValidAmount(amountUsd) {
  if (typeof amountUsd !== "number" || !Number.isFinite(amountUsd) || amountUsd <= 0 || amountUsd > 10000) {
    throw new functions.https.HttpsError("invalid-argument", "Qiime sax ah geli (0 ilaa 10000 USD).");
  }
}

// ---------------------------------------------------------------------------
// AUTO-SYNC: API-FOOTBALL to Firestore Matches
// ---------------------------------------------------------------------------
exports.syncDailyFixtures = onSchedule("0 2 * * *", async (event) => {
  await fetchAndSaveFixturesForToday();
});

exports.manualSyncFixtures = onRequest(async (req, res) => {
  try {
    await fetchAndSaveFixturesForToday();
    res.status(200).json({
      status: "Success",
      message: "Ciyaarihii maanta si guul leh ayaa looga soo jiiday API-ga loona geyey Firestore.",
    });
  } catch (error) {
    console.error("Error manual sync:", error);
    res.status(500).json({
      status: "Error",
      message: error.message,
    });
  }
});

async function fetchAndSaveFixturesForToday() {
  if (!API_KEY) {
    throw new Error("API_FOOTBALL_KEY is not configured in the Functions runtime.");
  }
  const todayStr = new Date().toISOString().split("T")[0]; // YYYY-MM-DD
  console.log(`Syncing fixtures for date: ${todayStr}`);

  const response = await axios.get(`https://${API_HOST}/fixtures`, {
    params: { date: todayStr },
    headers: {
      "x-apisports-key": API_KEY, // Beddel x-rapidapi-key haddii aad ka isticmaasho RapidAPI
    },
  });

  const fixtures = response.data.response;
  if (!fixtures || fixtures.length === 0) {
    console.log("Ma jiraan ciyaaro maanta la helay.");
    return;
  }

  const batch = db.batch();
  const matchesRef = db.collection("matches");

  for (const item of fixtures) {
    const matchId = String(item.fixture.id);
    const docRef = matchesRef.doc(matchId);

    const matchData = {
      id: matchId,
      sport: "football",
      league: {
        id: item.league.id,
        name: item.league.name,
        country: item.league.country,
        logo: item.league.logo,
      },
      teamAName: item.teams.home.name,
      teamALogo: item.teams.home.logo,
      teamBName: item.teams.away.name,
      teamBLogo: item.teams.away.logo,
      kooxA: item.teams.home.name,
      kooxALogo: item.teams.home.logo,
      kooxB: item.teams.away.name,
      kooxBLogo: item.teams.away.logo,
      scoreA: item.goals.home ?? 0,
      scoreB: item.goals.away ?? 0,
      status: mapStatus(item.fixture.status.short),
      startTime: item.fixture.date,
      fixtureDate: item.fixture.date,
      timestamp: admin.firestore.Timestamp.fromDate(new Date(item.fixture.date)),
      streamUrlHd: "",
      streamUrlSd: "",
      streamEnabled: false,
      reminderSent: false,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    batch.set(docRef, matchData, { merge: true });
  }

  await batch.commit();
  console.log(`Saved ${fixtures.length} matches to Firestore.`);
}

function mapStatus(shortStatus) {
  const liveCodes = ["1H", "HT", "2H", "ET", "P", "LIVE"];
  const finishedCodes = ["FT", "AET", "PEN"];
  if (liveCodes.includes(shortStatus)) return "live";
  if (finishedCodes.includes(shortStatus)) return "finished";
  return "upcoming";
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
// ---------------------------------------------------------------------------
exports.createEvcPlusPayment = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Waa inaad gashaa.");
  }
  const { phoneNumber, amountUsd } = data;
  if (typeof phoneNumber !== "string" || phoneNumber.trim().length < 7 || phoneNumber.trim().length > 20) {
    throw new functions.https.HttpsError("invalid-argument", "Lambarka & qiimaha waa loo baahan yahay.");
  }
  assertValidAmount(amountUsd);

  const merchantConfig = functions.config().hormuud || {};
  if (!merchantConfig.merchant_uid || !merchantConfig.api_key) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "EVC Plus merchant account lama qeexin."
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
// ---------------------------------------------------------------------------
exports.createUsdtPaymentIntent = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Waa inaad gashaa.");
  }
  const { amountUsd } = data;
  assertValidAmount(amountUsd);
  const walletConfig = functions.config().usdt || {};
  if (!walletConfig.deposit_address) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "USDT wallet lama qeexin."
    );
  }

  const paymentRef = db.collection("payments").doc();
  await paymentRef.set({
    uid: context.auth.uid,
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

exports.confirmUsdtWebhook = functions.https.onRequest(async (req, res) => {
  const secret = req.headers["x-webhook-secret"];
  const webhookSecret = (functions.config().usdt || {}).webhook_secret;
  if (!webhookSecret || secret !== webhookSecret) {
    return res.status(401).send("Unauthorized");
  }
  const { paymentId, txHash, confirmed } = req.body;
  if (!confirmed) return res.status(200).send("Ignored - not confirmed");

  const paymentRef = db.collection("payments").doc(paymentId);
  const payment = await paymentRef.get();
  if (!payment.exists) return res.status(404).send("Payment not found");
  if (payment.data().status === "confirmed") return res.status(200).send("Already confirmed");
  if (payment.data().status !== "pending") return res.status(409).send("Payment is not pending");
  if (typeof txHash !== "string" || txHash.trim().length < 8) {
    return res.status(400).send("Invalid transaction hash");
  }

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
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Waa inaad gashaa.");
  }
  const userDoc = await db.collection("users").doc(context.auth.uid).get();
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
// ADMIN: manage users
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
// ADMIN: broadcast push notification
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
          body: `${m.teamAName || m.kooxA} vs ${m.teamBName || m.kooxB} - 15 daqiiqo kadib`,
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
