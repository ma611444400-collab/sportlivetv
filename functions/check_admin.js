const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
const db = admin.firestore();

async function check() {
  const uid = "gm3nVJnWGsWIBSaG8kJ0d7j9AMw1";
  const doc = await db.collection("admins").doc(uid).get();

  if (doc.exists) {
    console.log("ADMIN DOC WUU JIRAA");
    console.log(doc.data());
  } else {
    console.log("ADMIN DOC MA JIRO");
    const all = await db.collection("admins").get();
    console.log("Tirada dukumeentiyada admins:", all.size);
    all.forEach((d) => console.log(d.id, d.data()));
  }
  process.exit(0);
}

check().catch((e) => {
  console.error(e);
  process.exit(1);
});
