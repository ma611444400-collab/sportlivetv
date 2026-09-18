import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/team_model.dart';
import '../data/global_sports_catalog.dart';
import 'favorite_teams_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fs = FirestoreService();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Center(child: Text('Fadlan gal si aad u aragto Favorites-kaaga'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          IconButton(
            tooltip: 'Dooro kooxo',
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FavoriteTeamsScreen())),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: fs.streamUser(uid),
        builder: (context, userSnap) {
        final favIds = userSnap.data?.favoriteTeamIds ?? [];
        return StreamBuilder(
          stream: fs.streamTeams(),
          builder: (context, teamSnap) {
            final teams = [...(teamSnap.data ?? const <TeamModel>[]), ...GlobalSportsCatalog.teams]
                .fold<Map<String, TeamModel>>({}, (map, team) {
                  map[team.id] = team;
                  return map;
                })
                .values
                .toList();
            final favTeams = teams.where((t) => favIds.contains(t.id)).toList();
            if (favTeams.isEmpty) {
              return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Ma haysatid koox aad ku darto favorites'),
                const SizedBox(height: 12),
                ElevatedButton.icon(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FavoriteTeamsScreen())), icon: const Icon(Icons.add), label: const Text('Dooro koox')),
              ]));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: favTeams.length,
              itemBuilder: (_, i) => _favTile(context, fs, uid!, favTeams[i]),
            );
          },
        );
        },
      ),
    );
  }

  Widget _favTile(BuildContext context, FirestoreService fs, String uid, TeamModel team) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(backgroundImage: NetworkImage(team.logoUrl)),
        title: Text(team.name),
        subtitle: Text(team.sport),
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: Colors.red),
          onPressed: () => fs.toggleFavorite(uid, team.id, false),
        ),
      ),
    );
  }
}
