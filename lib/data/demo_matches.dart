import '../models/match_model.dart';

/// Offline fallback used only when Firestore has no match documents.
/// The videos are Google's public sample files and are for player testing only.
class DemoMatches {
  static const _logo = 'https://cdn-icons-png.flaticon.com/512/53/53283.png';

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
      streamUrlHd: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      streamUrlSd: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
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
      streamUrlHd: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      streamUrlSd: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
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
EOF
mkdir -p /home/ubuntu/sportlivetv/lib/data
