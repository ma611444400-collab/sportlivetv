import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/live_score_model.dart';

class FavoriteMatchService {
  static const _key = 'favorite_live_matches';

  Future<List<LiveScoreModel>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? const <String>[];
    return raw.map((value) {
      try {
        return LiveScoreModel.fromFavoriteMap(jsonDecode(value) as Map<String, dynamic>);
      } catch (_) {
        return null;
      }
    }).whereType<LiveScoreModel>().toList();
  }

  Future<bool> contains(int fixtureId) async => (await load()).any((m) => m.fixtureId == fixtureId);

  Future<void> toggle(LiveScoreModel match) async {
    final prefs = await SharedPreferences.getInstance();
    final matches = await load();
    final existing = matches.indexWhere((m) => m.fixtureId == match.fixtureId);
    if (existing >= 0) {
      matches.removeAt(existing);
    } else {
      matches.insert(0, match);
    }
    await prefs.setStringList(_key, matches.map((m) => jsonEncode(m.toMap())).toList());
  }
}
