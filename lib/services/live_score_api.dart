import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/live_score_model.dart';

class LiveScoreApi {
  static const _baseUrl = 'https://v3.football.api-sports.io';
  static const apiKey = String.fromEnvironment('API_FOOTBALL_KEY');
  static const apiHost = String.fromEnvironment(
    'API_FOOTBALL_HOST',
    defaultValue: 'v3.football.api-sports.io',
  );

  bool get isConfigured => apiKey.trim().isNotEmpty;

  Future<List<LiveScoreModel>> liveFixtures() async {
    final data = await _get('/fixtures?live=all');
    return (data['response'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(LiveScoreModel.fromMap)
        .toList();
  }

  Future<List<LiveScoreModel>> fixturesByDate(DateTime date) async {
    final day = date.toIso8601String().substring(0, 10);
    final data = await _get('/fixtures?date=$day');
    return (data['response'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(LiveScoreModel.fromMap)
        .toList();
  }

  Future<LiveScoreModel?> fixtureWithEvents(int fixtureId) async {
    final fixtureData = await _get('/fixtures?id=$fixtureId');
    final response = fixtureData['response'] as List<dynamic>? ?? [];
    if (response.isEmpty || response.first is! Map<String, dynamic>) return null;
    final fixture = Map<String, dynamic>.from(response.first as Map);
    final eventsData = await _get('/fixtures/events?fixture=$fixtureId');
    fixture['events'] = eventsData['response'] ?? [];
    return LiveScoreModel.fromMap(fixture);
  }

  Future<List<StandingRow>> standings({required int league, required int season}) async {
    final data = await _get('/standings?league=$league&season=$season');
    final response = data['response'] as List<dynamic>? ?? [];
    if (response.isEmpty || response.first is! Map<String, dynamic>) return [];
    final leagueData = (response.first as Map<String, dynamic>)['league'] as Map<String, dynamic>? ?? {};
    final tables = leagueData['standings'] as List<dynamic>? ?? [];
    if (tables.isEmpty) return [];
    return (tables.first as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(StandingRow.fromMap)
        .toList();
  }

  Future<Map<String, dynamic>> _get(String path) async {
    if (!isConfigured) {
      throw const LiveScoreApiException('API key lama gelin. Ku dar API_FOOTBALL_KEY marka la build-gareynayo.');
    }
    final response = await http.get(
      Uri.parse('$_baseUrl$path'),
      headers: {'x-apisports-key': apiKey, 'x-rapidapi-host': apiHost},
    ).timeout(const Duration(seconds: 15));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LiveScoreApiException('Live score API error: HTTP ${response.statusCode}');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) throw const LiveScoreApiException('API response aan la fahmi karin.');
    final errors = decoded['errors'];
    if (errors is Map && errors.isNotEmpty) throw LiveScoreApiException(errors.values.join(', '));
    return decoded;
  }
}

class LiveScoreApiException implements Exception {
  final String message;
  const LiveScoreApiException(this.message);
  @override
  String toString() => message;
}
