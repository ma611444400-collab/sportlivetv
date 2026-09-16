import '../models/match_model.dart';

/// Offline fallback used only when Firestore has no match documents.
/// The video is a public sample used only for player testing.
class DemoMatches {
  static const _logo = 'asset:assets/images/app_logo.png';
  static const _testVideo = 'https://media.w3.org/2010/05/sintel/trailer.mp4';

  static final List<MatchModel> all = [
    MatchModel(
      id: 'demo_live_free',
      sport: 'football',
      league: 'Demo League · Player Test',
      teamAName: 'Demo FC',
      teamALogo: _logo,
      teamBName: 'Test United',
      teamBLogo: _logo,
      startTime: _now,
      status: 'live',
      scoreA: 1,
      scoreB: 0,
      streamEnabled: true,
      isFree: true,
      streamUrlHd: _testVideo,
      streamUrlSd: _testVideo,
      stats: {'Possession Demo FC': '58%', 'Shots on target': 4, 'Corners': 3},
    ),
    MatchModel(
      id: 'demo_live_premium',
      sport: 'ufc',
      league: 'Demo Fight Night · Premium Test',
      teamAName: 'Fighter A',
      teamALogo: _logo,
      teamBName: 'Fighter B',
      teamBLogo: _logo,
      startTime: _now,
      status: 'live',
      streamEnabled: true,
      isFree: false,
      streamUrlHd: _testVideo,
      streamUrlSd: _testVideo,
    ),
    MatchModel(
      id: 'demo_upcoming',
      sport: 'basketball',
      league: 'Demo Basketball Cup',
      teamAName: 'Red Hawks',
      teamALogo: _logo,
      teamBName: 'Blue Sharks',
      teamBLogo: _logo,
      startTime: _upcoming,
      status: 'upcoming',
      streamEnabled: true,
      isFree: true,
      streamUrlHd: _testVideo,
      streamUrlSd: _testVideo,
    ),
  ];

  static final DateTime _now = DateTime.now();
  static final DateTime _upcoming = DateTime.now().add(const Duration(minutes: 10));

  static List<MatchModel> live() => all.where((m) => m.status == 'live').toList();

  static List<MatchModel> upcoming({String? sport}) => all
      .where((m) => m.status == 'upcoming' && (sport == null || sport == 'all' || m.sport == sport))
      .toList();

  static MatchModel? byId(String id) {
    for (final match in all) {
      if (match.id == id) return match;
    }
    return null;
  }
}
