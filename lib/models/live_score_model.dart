class LiveScoreModel {
  final int fixtureId;
  final String league;
  final String country;
  final String homeName;
  final String homeLogo;
  final String awayName;
  final String awayLogo;
  final String status;
  final String statusShort;
  final int elapsed;
  final int homeGoals;
  final int awayGoals;
  final DateTime startTime;
  final List<GoalEvent> events;

  const LiveScoreModel({
    required this.fixtureId,
    required this.league,
    required this.country,
    required this.homeName,
    required this.homeLogo,
    required this.awayName,
    required this.awayLogo,
    required this.status,
    required this.statusShort,
    required this.elapsed,
    required this.homeGoals,
    required this.awayGoals,
    required this.startTime,
    this.events = const [],
  });

  factory LiveScoreModel.fromMap(Map<String, dynamic> map) {
    final fixture = map['fixture'] as Map<String, dynamic>? ?? {};
    final teams = map['teams'] as Map<String, dynamic>? ?? {};
    final goals = map['goals'] as Map<String, dynamic>? ?? {};
    final league = map['league'] as Map<String, dynamic>? ?? {};
    final status = fixture['status'] as Map<String, dynamic>? ?? {};
    final home = teams['home'] as Map<String, dynamic>? ?? {};
    final away = teams['away'] as Map<String, dynamic>? ?? {};
    return LiveScoreModel(
      fixtureId: (fixture['id'] as num?)?.toInt() ?? 0,
      league: league['name'] ?? '',
      country: league['country'] ?? '',
      homeName: home['name'] ?? '',
      homeLogo: home['logo'] ?? '',
      awayName: away['name'] ?? '',
      awayLogo: away['logo'] ?? '',
      status: status['long'] ?? 'Unknown',
      statusShort: status['short'] ?? 'NS',
      elapsed: (status['elapsed'] as num?)?.toInt() ?? 0,
      homeGoals: (goals['home'] as num?)?.toInt() ?? 0,
      awayGoals: (goals['away'] as num?)?.toInt() ?? 0,
      startTime: DateTime.tryParse(fixture['date'] ?? '') ?? DateTime.now(),
      events: (map['events'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(GoalEvent.fromMap)
          .where((event) => event.type == 'Goal')
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
        'fixtureId': fixtureId,
        'league': league,
        'country': country,
        'homeName': homeName,
        'homeLogo': homeLogo,
        'awayName': awayName,
        'awayLogo': awayLogo,
        'status': status,
        'statusShort': statusShort,
        'elapsed': elapsed,
        'homeGoals': homeGoals,
        'awayGoals': awayGoals,
        'startTime': startTime.toIso8601String(),
        'events': events.map((e) => e.toMap()).toList(),
      };

  factory LiveScoreModel.fromFavoriteMap(Map<String, dynamic> map) => LiveScoreModel(
        fixtureId: (map['fixtureId'] as num?)?.toInt() ?? 0,
        league: map['league'] ?? '',
        country: map['country'] ?? '',
        homeName: map['homeName'] ?? '',
        homeLogo: map['homeLogo'] ?? '',
        awayName: map['awayName'] ?? '',
        awayLogo: map['awayLogo'] ?? '',
        status: map['status'] ?? 'Unknown',
        statusShort: map['statusShort'] ?? 'NS',
        elapsed: (map['elapsed'] as num?)?.toInt() ?? 0,
        homeGoals: (map['homeGoals'] as num?)?.toInt() ?? 0,
        awayGoals: (map['awayGoals'] as num?)?.toInt() ?? 0,
        startTime: DateTime.tryParse(map['startTime'] ?? '') ?? DateTime.now(),
        events: (map['events'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(GoalEvent.fromFavoriteMap)
            .toList(),
      );
}

class GoalEvent {
  final int elapsed;
  final String? extra;
  final String player;
  final String team;
  final String type;
  final String detail;

  const GoalEvent({
    required this.elapsed,
    required this.extra,
    required this.player,
    required this.team,
    required this.type,
    required this.detail,
  });

  factory GoalEvent.fromMap(Map<String, dynamic> map) {
    final time = map['time'] as Map<String, dynamic>? ?? {};
    final player = map['player'] as Map<String, dynamic>? ?? {};
    final team = map['team'] as Map<String, dynamic>? ?? {};
    return GoalEvent(
      elapsed: (time['elapsed'] as num?)?.toInt() ?? 0,
      extra: time['extra']?.toString(),
      player: player['name'] ?? 'Unknown',
      team: team['name'] ?? '',
      type: map['type'] ?? '',
      detail: map['detail'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'elapsed': elapsed,
        'extra': extra,
        'player': player,
        'team': team,
        'type': type,
        'detail': detail,
      };

  factory GoalEvent.fromFavoriteMap(Map<String, dynamic> map) => GoalEvent(
        elapsed: (map['elapsed'] as num?)?.toInt() ?? 0,
        extra: map['extra']?.toString(),
        player: map['player'] ?? 'Unknown',
        team: map['team'] ?? '',
        type: map['type'] ?? 'Goal',
        detail: map['detail'] ?? '',
      );
}

class StandingRow {
  final int rank;
  final String team;
  final String logo;
  final int points;
  final int played;
  final int goalDifference;

  const StandingRow({
    required this.rank,
    required this.team,
    required this.logo,
    required this.points,
    required this.played,
    required this.goalDifference,
  });

  factory StandingRow.fromMap(Map<String, dynamic> map) {
    final team = map['team'] as Map<String, dynamic>? ?? {};
    return StandingRow(
      rank: (map['rank'] as num?)?.toInt() ?? 0,
      team: team['name'] ?? '',
      logo: team['logo'] ?? '',
      points: (map['points'] as num?)?.toInt() ?? 0,
      played: (map['all']?['played'] as num?)?.toInt() ?? 0,
      goalDifference: (map['goalsDiff'] as num?)?.toInt() ?? 0,
    );
  }
}
