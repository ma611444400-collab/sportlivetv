import 'package:flutter/material.dart';
import '../models/live_score_model.dart';
import '../services/favorite_match_service.dart';
import '../theme/app_theme.dart';

class FavoriteMatchesScreen extends StatefulWidget {
  const FavoriteMatchesScreen({super.key});

  @override
  State<FavoriteMatchesScreen> createState() => _FavoriteMatchesScreenState();
}

class _FavoriteMatchesScreenState extends State<FavoriteMatchesScreen> {
  final _service = FavoriteMatchService();
  late Future<List<LiveScoreModel>> _matches;

  @override
  void initState() {
    super.initState();
    _matches = _service.load();
  }

  void _reload() => setState(() => _matches = _service.load());

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Ciyaaraha aan jeclahay'),
          actions: [IconButton(onPressed: _reload, icon: const Icon(Icons.refresh))],
        ),
        body: FutureBuilder<List<LiveScoreModel>>(
          future: _matches,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final matches = snapshot.data ?? const <LiveScoreModel>[];
            if (matches.isEmpty) {
              return const Center(child: Text('Wali ciyaar Favorites ah ma lihid. Taabo xiddigta Live Scores.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: matches.length,
              itemBuilder: (_, index) {
                final match = matches[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const Icon(Icons.sports_soccer, color: AppColors.primary),
                    title: Text('${match.homeName} ${match.homeGoals} - ${match.awayGoals} ${match.awayName}'),
                    subtitle: Text('${match.league} · ${match.statusShort}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.star, color: Colors.amber),
                      onPressed: () async {
                        await _service.toggle(match);
                        _reload();
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
}
