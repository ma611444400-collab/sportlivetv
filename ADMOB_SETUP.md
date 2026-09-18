# AdMob monetization setup

SportLiveTV now includes Google Mobile Ads banner support and an interstitial-ready service. Development uses Google's official test application and banner/interstitial IDs, so no real impressions or revenue are generated during testing.

## Production setup

Create an Android app in AdMob and add these GitHub Actions repository secrets or build defines:

```text
ADMOB_ANDROID_APP_ID
ADMOB_ANDROID_BANNER_ID
ADMOB_ANDROID_INTERSTITIAL_ID
```

The app can be built with:

```bash
flutter build apk --release \
  --dart-define=ADMOB_ANDROID_APP_ID=ca-app-pub-XXXX~YYYY \
  --dart-define=ADMOB_ANDROID_BANNER_ID=ca-app-pub-XXXX/BBBB \
  --dart-define=ADMOB_ANDROID_INTERSTITIAL_ID=ca-app-pub-XXXX/IIII \
  --dart-define=API_FOOTBALL_KEY=YOUR_API_KEY
```

Do not click test ads for revenue, and do not use production IDs during development. Before Google Play release, complete AdMob app verification, publisher identity/payment setup, age/content declarations, and the Google User Messaging Platform consent configuration for the regions where ads are served.

## Product behavior

A banner appears in the Home feed. Premium users can hide ads through the Profile premium control. Interstitial loading is available in `AdService` for future use at natural transitions; it should not be shown while a user is watching a live match or entering payment details.
