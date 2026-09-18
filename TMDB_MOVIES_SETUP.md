# Legal Movies feature

SportLiveTV now has a Movies tab for discovering current releases and popular films. It uses TMDB for metadata, posters, summaries, ratings, trailers, and country-aware official watch-provider links.

## Configure TMDB

Create a TMDB API Read Access Token and add it as a GitHub Actions repository secret named:

```text
TMDB_API_KEY
```

The Android build should pass it securely:

```yaml
env:
  TMDB_API_KEY: ${{ secrets.TMDB_API_KEY }}
run: flutter build apk --debug --dart-define=TMDB_API_KEY="$TMDB_API_KEY"
```

Without the token, the Movies tab shows a clear configuration message and does not use unofficial sources.

## Legal behavior

The app does not host, copy, download, or provide pirate links for films. The `Daawo trailer` action opens the official YouTube trailer. The `Daawo si rasmi ah` action opens the official country-specific provider page returned by TMDB/JustWatch data when available. Availability depends on the user's country and provider subscriptions.

TMDB attribution is shown in the Movies screen, and the app should also include approved TMDB branding in the store/about page before production release.
