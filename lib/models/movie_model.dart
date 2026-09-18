class MovieModel {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final String releaseDate;
  final double rating;
  final List<int> genreIds;
  final String? trailerKey;
  final String? officialWatchUrl;

  const MovieModel({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.releaseDate,
    required this.rating,
    required this.genreIds,
    this.trailerKey,
    this.officialWatchUrl,
  });

  factory MovieModel.fromMap(Map<String, dynamic> map) => MovieModel(
        id: (map['id'] as num?)?.toInt() ?? 0,
        title: map['title'] ?? map['name'] ?? 'Unknown title',
        overview: map['overview'] ?? '',
        posterPath: map['poster_path'] ?? '',
        backdropPath: map['backdrop_path'] ?? '',
        releaseDate: map['release_date'] ?? '',
        rating: (map['vote_average'] as num?)?.toDouble() ?? 0,
        genreIds: (map['genre_ids'] as List<dynamic>? ?? []).whereType<num>().map((e) => e.toInt()).toList(),
        trailerKey: map['trailerKey'],
        officialWatchUrl: map['officialWatchUrl'],
      );

  MovieModel copyWith({String? trailerKey, String? officialWatchUrl}) => MovieModel(
        id: id, title: title, overview: overview, posterPath: posterPath, backdropPath: backdropPath,
        releaseDate: releaseDate, rating: rating, genreIds: genreIds,
        trailerKey: trailerKey ?? this.trailerKey, officialWatchUrl: officialWatchUrl ?? this.officialWatchUrl,
      );
}
