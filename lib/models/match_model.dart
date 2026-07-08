class MatchModel {
  final String id;
  final String sport; // football, basketball, tennis, cricket, ufc, boxing...
  final String league;
  final String teamAName;
  final String teamALogo;
  final String teamBName;
  final String teamBLogo;
  final DateTime startTime;
  final String status; // upcoming, live, finished
  final int scoreA;
  final int scoreB;
  final bool streamEnabled; // admin toggle
  final bool isFree; // admin can flip any match to free viewing, bypassing Premium check
  final String? streamUrlHd; // MUST be an authorized/licensed source, set by admin only
  final String? streamUrlSd;
  final Map<String, dynamic>? stats;

  MatchModel({
    required this.id,
    required this.sport,
    required this.league,
    required this.teamAName,
    required this.teamALogo,
    required this.teamBName,
    required this.teamBLogo,
    required this.startTime,
    this.status = 'upcoming',
    this.scoreA = 0,
    this.scoreB = 0,
    this.streamEnabled = false,
    this.isFree = false,
    this.streamUrlHd,
    this.streamUrlSd,
    this.stats,
  });

  factory MatchModel.fromMap(String id, Map<String, dynamic> map) {
    return MatchModel(
      id: id,
      sport: map['sport'] ?? '',
      league: map['league'] ?? '',
      teamAName: map['teamAName'] ?? '',
      teamALogo: map['teamALogo'] ?? '',
      teamBName: map['teamBName'] ?? '',
      teamBLogo: map['teamBLogo'] ?? '',
      startTime: DateTime.tryParse(map['startTime'] ?? '') ?? DateTime.now(),
      status: map['status'] ?? 'upcoming',
      scoreA: map['scoreA'] ?? 0,
      scoreB: map['scoreB'] ?? 0,
      streamEnabled: map['streamEnabled'] ?? false,
      isFree: map['isFree'] ?? false,
      streamUrlHd: map['streamUrlHd'],
      streamUrlSd: map['streamUrlSd'],
      stats: map['stats'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sport': sport,
      'league': league,
      'teamAName': teamAName,
      'teamALogo': teamALogo,
      'teamBName': teamBName,
      'teamBLogo': teamBLogo,
      'startTime': startTime.toIso8601String(),
      'status': status,
      'scoreA': scoreA,
      'scoreB': scoreB,
      'streamEnabled': streamEnabled,
      'isFree': isFree,
      'streamUrlHd': streamUrlHd,
      'streamUrlSd': streamUrlSd,
      'stats': stats,
    };
  }
}
