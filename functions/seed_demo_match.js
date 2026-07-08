/**
 * DEMO SEED SCRIPT — waxaan ku darayaa hal ciyaar "demo" ah oo leh video
 * bilaash & sharci ah (Big Buck Bunny, Creative Commons) si aad u tijaabiso
 * sida app-ku u shaqeeyo (HD/SD toggle, premium gate, live badge, iwm)
 * OO AAN loo baahnayn ilo xaq-darro ah.
 *
 * Sida loo isticmaalo:
 *   1. cd sport_live_tv/functions
 *   2. npm install firebase-admin (haddii aanad hore u lahayn)
 *   3. Soo deji Service Account key-gaaga Firebase Console:
 *        Project Settings > Service Accounts > Generate new private key
 *      Kaydi sida "serviceAccountKey.json" gudaha /functions
 *   4. node seed_demo_match.js
 *
 * Kadib app-ka ordi: `flutter run` — waxaad ka arki doontaa "Demo FC vs Test United"
 * oo LIVE ah oo leh stream shaqeynaya.
 */

const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
const db = admin.firestore();

async function seed() {
  // 1. Demo match — LIVE, streamEnabled = true, isFree = true (dhammaan users way daawan karaan)
  await db.collection("matches").doc("demo_match_1").set({
    sport: "football",
    league: "Demo League (FREE)",
    teamAName: "Demo FC",
    teamALogo: "https://cdn-icons-png.flaticon.com/512/53/53283.png",
    teamBName: "Test United",
    teamBLogo: "https://cdn-icons-png.flaticon.com/512/53/53283.png",
    startTime: new Date().toISOString(),
    status: "live",
    scoreA: 1,
    scoreB: 0,
    streamEnabled: true,
    isFree: true,
    // Google's public sample videos — Creative Commons, si loo tijaabiyo player-ka oo keliya
    streamUrlHd: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
    streamUrlSd: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
    stats: { "Possession Demo FC": "58%", "Shots on Target": 4, "Corners": 3 },
    reminderSent: true,
  });

  // 1b. Demo match — LIVE, isFree = false (Premium keliya) si aad u aragto lock-ga
  await db.collection("matches").doc("demo_match_3").set({
    sport: "ufc",
    league: "Demo Fight Night (PREMIUM)",
    teamAName: "Fighter A",
    teamALogo: "https://cdn-icons-png.flaticon.com/512/53/53283.png",
    teamBName: "Fighter B",
    teamBLogo: "https://cdn-icons-png.flaticon.com/512/53/53283.png",
    startTime: new Date().toISOString(),
    status: "live",
    scoreA: 0,
    scoreB: 0,
    streamEnabled: true,
    isFree: false,
    streamUrlHd: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
    streamUrlSd: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
    stats: null,
    reminderSent: true,
  });

  // 2. Upcoming demo match (to test countdown timer)
  const in10Min = new Date(Date.now() + 10 * 60 * 1000);
  await db.collection("matches").doc("demo_match_2").set({
    sport: "basketball",
    league: "Demo Basketball Cup",
    teamAName: "Red Hawks",
    teamALogo: "https://cdn-icons-png.flaticon.com/512/53/53283.png",
    teamBName: "Blue Sharks",
    teamBLogo: "https://cdn-icons-png.flaticon.com/512/53/53283.png",
    startTime: in10Min.toISOString(),
    status: "upcoming",
    scoreA: 0,
    scoreB: 0,
    streamEnabled: false,
    reminderSent: false,
  });

  // 3. Demo teams (for Search + Favorites testing)
  await db.collection("teams").doc("team_demo_fc").set({
    name: "Demo FC",
    logoUrl: "https://cdn-icons-png.flaticon.com/512/53/53283.png",
    sport: "football",
    country: "Somalia",
  });
  await db.collection("teams").doc("team_test_united").set({
    name: "Test United",
    logoUrl: "https://cdn-icons-png.flaticon.com/512/53/53283.png",
    sport: "football",
    country: "Somalia",
  });

  // 4. Default subscription price config
  await db.collection("config").doc("subscription").set({ priceUsd: 0.60 });

  console.log("✅ Demo data waa la geliyay Firestore. Hadda `flutter run` samee.");
  process.exit(0);
}

seed().catch((e) => {
  console.error("❌ Khalad:", e);
  process.exit(1);
});
