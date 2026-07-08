class TeamModel {
  final String id;
  final String name;
  final String logoUrl;
  final String sport;
  final String country;

  TeamModel({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.sport,
    required this.country,
  });

  factory TeamModel.fromMap(String id, Map<String, dynamic> map) {
    return TeamModel(
      id: id,
      name: map['name'] ?? '',
      logoUrl: map['logoUrl'] ?? '',
      sport: map['sport'] ?? '',
      country: map['country'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'logoUrl': logoUrl,
        'sport': sport,
        'country': country,
      };
}
