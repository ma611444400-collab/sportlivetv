# Live Scores API Setup

The app now includes a **Live Scores** screen backed by API-Football/API-Sports. It refreshes live fixtures every 30 seconds and shows teams, logos, score, match minute/status, league, country, and goal events when a match is opened.

## Configure the key

Do not commit the API key to GitHub. Build the Android APK with a Dart compile-time define:

```bash
flutter build apk --debug --dart-define=API_FOOTBALL_KEY=YOUR_KEY
```

The client uses `https://v3.football.api-sports.io` and sends the key in the `x-apisports-key` header. The API host can be changed with:

```bash
--dart-define=API_FOOTBALL_HOST=v3.football.api-sports.io
```

The app currently shows a clear Somali setup message when the key is not configured, rather than pretending that live data is available.

## App behavior

From Home, tap the scoreboard icon beside the SportLiveTV title to open **Live Scores**. The screen refreshes every 30 seconds and supports pull-to-refresh. Tapping a match loads its goal events from the fixture-events endpoint. API errors show a retry action.

## Endpoints used

- `GET /fixtures?live=all`
- `GET /fixtures?date=YYYY-MM-DD`
- `GET /fixtures?id=FIXTURE_ID`
- `GET /fixtures/events?fixture=FIXTURE_ID`
- `GET /standings?league=LEAGUE_ID&season=SEASON`
