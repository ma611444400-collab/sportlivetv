# SportLiveTV — Tilmaamaha Dhismaha & Daabacaadda

Mashruucan wuxuu ka kooban yahay saddex qayb:
1. **`/sport_live_tv`** — Flutter mobile app (Android + iOS)
2. **`/sport_live_tv/functions`** — Firebase Cloud Functions (backend: payments, admin, notifications)
3. **`/admin_panel`** — React web Admin Dashboard

---

## 1. Diyaarinta Firebase Project

1. Tag [console.firebase.google.com](https://console.firebase.google.com) → **Add project** → magaca "SportLiveTV".
2. Ku shid (enable): **Authentication** (Email/Password + Phone), **Firestore Database**, **Storage**, **Cloud Messaging**, **Functions** (u baahan Blaze plan — Functions waa lacag bixin ku shaqeeya isla markaana leeyahay free tier).
3. Rakib Firebase CLI: `npm install -g firebase-tools`
4. `firebase login`
5. Gudaha `/sport_live_tv`, orod: `firebase use --add` → dooro project-kaaga.

## 2. Flutter App Setup

```bash
cd sport_live_tv
flutter pub get
dart pub global activate flutterfire_cli
flutterfire configure --project=<your-project-id>
```

Tan dambe (`flutterfire configure`) waxay si otomaatig ah u soo dhigi doontaa `lib/firebase_options.dart` oo leh API keys dhab ah — kaas oo ku beddelaya faylka placeholder-ka ah ee aan horey u sameeyay.

### Ordidda App-ka (development)
```bash
flutter run
```

### Build APK/AAB (production)
```bash
flutter build apk --release        # APK - Android direct install
flutter build appbundle --release  # AAB - Google Play Store
flutter build ipa --release        # iOS - App Store (u baahan Mac + Xcode)
```

Faylasha soo baxa waxaad ka heli doontaa:
- `build/app/outputs/flutter-apk/app-release.apk`
- `build/app/outputs/bundle/release/app-release.aab`

## 3. Cloud Functions (Backend)

```bash
cd functions
npm install
```

### U qeexid EVC Plus (Hormuud) Merchant Credentials
Waxaad u baahan tahay **merchant account** oo dhab ah oo aad ka heshid Hormuud Telecom (WaafiPay/EVC Plus API). Marka aad heshid:

```bash
firebase functions:config:set \
  hormuud.merchant_uid="XXXX" \
  hormuud.api_user_id="XXXX" \
  hormuud.api_key="XXXX" \
  hormuud.api_url="https://api.waafipay.net/asm"
```

### U qeexid USDT (TRC20) Wallet
Waxaad u baahan tahay wallet address (TRC20) iyo, haddii aad isticmaali doonto webhook xaqiijin otomaatig ah, adeeg saddexaad sida TronGrid ama BitGo si loo hubiyo lacagta timid.

```bash
firebase functions:config:set \
  usdt.deposit_address="T...your_trc20_address" \
  usdt.webhook_secret="samee_password_adag"
```

### Deploy Functions
```bash
firebase deploy --only functions
firebase deploy --only firestore:rules,firestore:indexes,storage
```

## 4. Sameynta Admin Account-ka Ugu Horeysa

Marka aad hore u samayso account (Sign up) app-ka mobile-ka, tag Firestore Console → ku dar dukumeenti cusub:

```
Collection: admins
Document ID: <your-firebase-auth-uid>
Fields: { role: "superadmin", createdAt: <timestamp> }
```

Kani ayaa kuu oggolaanaya inaad Admin Dashboard-ka isticmaasho.

## 5. Admin Panel (React Web)

```bash
cd admin_panel
npm install
```

Ku beddel qiimayaasha `src/firebase.js` kuwaaga dhabta ah (Project settings → Web app → SDK config).

### Ordidda development
```bash
npm run dev
```

### Deploy Admin Panel (Firebase Hosting)
```bash
npm run build
cd ..
firebase deploy --only hosting
```

Admin-ku wuxuu ku geli doonaa email/password-kiisa (isla email-ka uu ku diiwaan geli app-ka mobile-ka, ama account gaar ah oo Auth ah oo aad admin ka dhigto).

## 6. Qiimaha Subscription-ka ($0.60)

Qiimaha default-ka ah waa `$0.60`, waxaana lagu beddeli karaa goob kasta:
- Admin Panel → **Premium & Qiimaha** bogga
- Beddelku wuxuu si toos ah isaga bedelaa app-ka mobile-ka (wuxuu ka soo aqriyaa `getSubscriptionPrice` function-ka).

## 7. Muhiim — Ilaha Live Stream-ka

Meesha aad geliso `streamUrlHd` / `streamUrlSd` ee Admin Panel → **Matches**, waa inay ahaadaan **ilo aad rukhsad dhab ah u leedahay** (sida: laydh-kaaga, embed ka rukhsad leh, ama feed uu ku siiyo hay'ad rukhsad leh). Habka farsamaysan ee app-ku sameeyo — daawashada — waa mid caadi ah (video player URL), laakiin masuuliyadda sharciga ah ee content-ka ku jira link-ga waa taada.

## 8. Publishing Checklist

- [ ] Firebase project Blaze plan (u baahan Functions)
- [ ] `flutterfire configure` la ordiyay, `firebase_options.dart` waa dhab
- [ ] EVC Plus merchant credentials la geliyay
- [ ] USDT wallet address la geliyay
- [ ] App icon & splash screen (`assets/images/`) la geliyay — hadda waa placeholder
- [ ] Privacy Policy URL (waajib Google Play & App Store)
- [ ] Google Play Console account ($25 hal mar) + AAB upload
- [ ] Apple Developer account ($99/sano) + Xcode archive + App Store Connect

## 9. CI/CD — Build Otomaatig ah (GitHub Actions ama Codemagic)

Mashruucan wuxuu leeyahay laba ikhtiyaar oo CI/CD ah — dooro mid:

### Ikhtiyaar A: GitHub Actions (bilaash, ku jira `.github/workflows/`)
- `android-build.yml` — build-geeya APK + AAB mar kasta oo aad push-geyso `main`, ama gacan ahaan (`workflow_dispatch`).
- `ios-build.yml` — build-geeya IPA (u baahan macOS runner, waxaana la orday marka aad samayso git tag `v1.0.0` ama gacan ahaan).
- `deploy-backend.yml` — deploy otomaatig Cloud Functions + Firestore rules marka `functions/` ama `firebase/` isbeddelo.
- (Admin panel) `admin_panel/.github/workflows/deploy-admin.yml` — build + deploy Admin Dashboard-ka Firebase Hosting.

**Secrets waajibka ah ee GitHub Repo Settings → Secrets and variables → Actions:**
| Secret | Sida loo helo |
|---|---|
| `FIREBASE_OPTIONS_DART_B64` | `base64 -w0 lib/firebase_options.dart` kadib `flutterfire configure` |
| `ANDROID_KEYSTORE_BASE64` | `base64 -w0 release.keystore` |
| `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_PASSWORD`, `ANDROID_KEY_ALIAS` | markaad `keytool` samaynayso |
| `FIREBASE_TOKEN` | `firebase login:ci` |
| `FIREBASE_PROJECT_ID` | Project ID-ga Firebase |
| `IOS_CERTIFICATE_BASE64`, `IOS_CERTIFICATE_PASSWORD` | export `.p12` ka Xcode/Keychain |
| `IOS_PROVISION_PROFILE_BASE64` | Apple Developer portal |

Ka dib marka aad geliso secrets-ka, u tag GitHub repo-gaaga → **Actions** tab → orod workflow-yada gacan ahaan (`Run workflow`) ama kaliya push samee.

### Ikhtiyaar B: Codemagic (`codemagic.yaml`)
Codemagic waa mid ka fudud xagga iOS code-signing (integration UI ayay leedahay oo la xiriira Apple Developer si toos ah, halkii aad certificates gacanta ugu bedbedeli lahayd). Tallaabooyinka:
1. Tag [codemagic.io](https://codemagic.io) → connect GitHub repo-gaaga.
2. Ku dar environment variable group `firebase_credentials` (ku jira `FIREBASE_OPTIONS_DART_B64`).
3. Teams → Integrations → ku xir App Store Connect account-kaaga (Codemagic ayaa maamula signing-ka).
4. Bilaw build (workflow: `sportlivetv-android` ama `sportlivetv-ios`).

---

## 10. Waxa Aan Diyaarin — Waxaad U Baahan Tahay Inaad Adigu Sameyso

- Merchant/API credentials dhabta ah ee EVC Plus & USDT (sabab: xisaabaad shakhsi/ganacsi ah oo aan awoodin inaan kuu sameeyo)
- App icon, screenshots, iyo sawirro/logos-ka kooxaha & leagues-ka (copyright-ka sawirrada waa inuu ahaadaa mid aad xaq u leedahay)
- Ilaha stream-ka ee la isticmaali doono (rukhsad ahaan)
- Developer accounts (Google Play & Apple)
