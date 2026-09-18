import '../models/team_model.dart';

class GlobalLeague {
  final int id;
  final String name;
  final String country;
  final String flag;
  const GlobalLeague(this.id, this.name, this.country, this.flag);
}

class GlobalSportsCatalog {
  static const leagues = <GlobalLeague>[
    GlobalLeague(39, 'Premier League', 'England', '🇬🇧'),
    GlobalLeague(140, 'La Liga', 'Spain', '🇪🇸'),
    GlobalLeague(135, 'Serie A', 'Italy', '🇮🇹'),
    GlobalLeague(78, 'Bundesliga', 'Germany', '🇩🇪'),
    GlobalLeague(61, 'Ligue 1', 'France', '🇫🇷'),
    GlobalLeague(2, 'UEFA Champions League', 'Europe', '⭐'),
    GlobalLeague(3, 'UEFA Europa League', 'Europe', '🏆'),
    GlobalLeague(88, 'Eredivisie', 'Netherlands', '🇳🇱'),
    GlobalLeague(94, 'Primeira Liga', 'Portugal', '🇵🇹'),
    GlobalLeague(253, 'MLS', 'USA', '🇺🇸'),
    GlobalLeague(307, 'Saudi Pro League', 'Saudi Arabia', '🇸🇦'),
    GlobalLeague(203, 'Süper Lig', 'Türkiye', '🇹🇷'),
  ];

  static const teams = <TeamModel>[
    TeamModel(id: 'arsenal', name: 'Arsenal', logoUrl: 'https://media.api-sports.io/football/teams/42.png', sport: 'football', country: 'England'),
    TeamModel(id: 'liverpool', name: 'Liverpool', logoUrl: 'https://media.api-sports.io/football/teams/40.png', sport: 'football', country: 'England'),
    TeamModel(id: 'man-city', name: 'Manchester City', logoUrl: 'https://media.api-sports.io/football/teams/50.png', sport: 'football', country: 'England'),
    TeamModel(id: 'man-united', name: 'Manchester United', logoUrl: 'https://media.api-sports.io/football/teams/33.png', sport: 'football', country: 'England'),
    TeamModel(id: 'chelsea', name: 'Chelsea', logoUrl: 'https://media.api-sports.io/football/teams/49.png', sport: 'football', country: 'England'),
    TeamModel(id: 'real-madrid', name: 'Real Madrid', logoUrl: 'https://media.api-sports.io/football/teams/541.png', sport: 'football', country: 'Spain'),
    TeamModel(id: 'barcelona', name: 'Barcelona', logoUrl: 'https://media.api-sports.io/football/teams/529.png', sport: 'football', country: 'Spain'),
    TeamModel(id: 'atletico', name: 'Atlético Madrid', logoUrl: 'https://media.api-sports.io/football/teams/530.png', sport: 'football', country: 'Spain'),
    TeamModel(id: 'juventus', name: 'Juventus', logoUrl: 'https://media.api-sports.io/football/teams/496.png', sport: 'football', country: 'Italy'),
    TeamModel(id: 'inter', name: 'Inter Milan', logoUrl: 'https://media.api-sports.io/football/teams/505.png', sport: 'football', country: 'Italy'),
    TeamModel(id: 'ac-milan', name: 'AC Milan', logoUrl: 'https://media.api-sports.io/football/teams/489.png', sport: 'football', country: 'Italy'),
    TeamModel(id: 'bayern', name: 'Bayern Munich', logoUrl: 'https://media.api-sports.io/football/teams/157.png', sport: 'football', country: 'Germany'),
    TeamModel(id: 'psg', name: 'Paris Saint-Germain', logoUrl: 'https://media.api-sports.io/football/teams/85.png', sport: 'football', country: 'France'),
    TeamModel(id: 'ajax', name: 'Ajax', logoUrl: 'https://media.api-sports.io/football/teams/194.png', sport: 'football', country: 'Netherlands'),
    TeamModel(id: 'al-hilal', name: 'Al Hilal', logoUrl: 'https://media.api-sports.io/football/teams/2932.png', sport: 'football', country: 'Saudi Arabia'),
  ];
}
