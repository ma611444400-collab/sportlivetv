import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie_model.dart';

class TmdbService {
  static const _baseUrl = 'https://api.themoviedb.org/3';
  static const _imageBase = 'https://image.tmdb.org/t/p/w500';
  static const apiKey = String.fromEnvironment('TMDB_API_KEY');

  bool get isConfigured => apiKey.trim().isNotEmpty;
  String imageUrl(String path) => path.isEmpty ? '' : '$_imageBase$path';

  Future<List<MovieModel>> nowPlaying({String region = 'SO'}) async => _movies('/movie/now_playing?language=en-US&region=$region');
  Future<List<MovieModel>> popular() async => _movies('/movie/popular?language=en-US&page=1');
  Future<List<MovieModel>> search(String query) async {
    if (query.trim().isEmpty) return popular();
    return _movies('/search/movie?language=en-US&query=${Uri.encodeQueryComponent(query.trim())}&include_adult=false&page=1');
  }

  Future<MovieModel> enrich(MovieModel movie, {String region = 'SO'}) async {
    final details = await _get('/movie/${movie.id}?language=en-US&append_to_response=videos,watch/providers');
    final videos = (details['videos']?['results'] as List<dynamic>? ?? []).whereType<Map<String, dynamic>>();
    final trailer = videos.firstWhere((v) => v['site'] == 'YouTube' && v['type'] == 'Trailer' && v['official'] == true, orElse: () => videos.firstWhere((v) => v['site'] == 'YouTube' && v['type'] == 'Trailer', orElse: () => <String, dynamic>{}));
    final country = details['watch/providers']?['results']?[region] as Map<String, dynamic>?;
    final providerUrl = country?['link']?.toString();
    final officialUrl = providerUrl ?? 'https://www.themoviedb.org/movie/${movie.id}/watch?locale=$region';
    return movie.copyWith(trailerKey: trailer['key']?.toString(), officialWatchUrl: officialUrl);
  }

  Future<List<MovieModel>> _movies(String path) async {
    final data = await _get(path);
    return (data['results'] as List<dynamic>? ?? []).whereType<Map<String, dynamic>>().map(MovieModel.fromMap).toList();
  }

  Future<Map<String, dynamic>> _get(String path) async {
    if (!isConfigured) throw const TmdbException('TMDB API key lama gelin. Ku dar TMDB_API_KEY marka la build-gareynayo.');
    final token = apiKey.trim();
    // TMDB has two credential formats: the legacy v3 API key and the v4
    // read-access token. Supporting both avoids a confusing 401 when a user
    // copies the API key shown in the TMDB dashboard instead of the token.
    final isV4Token = token.contains('.') && token.length > 80;
    final uri = isV4Token
        ? Uri.parse('$_baseUrl$path')
        : Uri.parse('$_baseUrl$path${path.contains('?') ? '&' : '?'}api_key=${Uri.encodeQueryComponent(token)}');
    final headers = <String, String>{'accept': 'application/json'};
    if (isV4Token) headers['Authorization'] = 'Bearer $token';
    final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 15));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final hint = response.statusCode == 401 ? ' Hubi in TMDB_API_KEY uu yahay API Key ama Read Access Token sax ah.' : '';
      throw TmdbException('TMDB error: HTTP ${response.statusCode}.$hint');
    }
    final data = jsonDecode(response.body);
    if (data is! Map<String, dynamic>) throw const TmdbException('TMDB response aan la fahmi karin.');
    return data;
  }
}

class TmdbException implements Exception {
  final String message;
  const TmdbException(this.message);
  @override
  String toString() => message;
}
