import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/team_model.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fs = FirestoreService();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder(
      stream: uid != null ? fs.streamUser(uid) : null,
      builder: (context, userSnap) {
        final favIds = userSnap.data?.favoriteTeamIds ?? [];
        return StreamBuilder(
          stream: fs.streamTeams(),
          builder: (context, teamSnap) {
            if (!teamSnap.hasData) return const Center(child: CircularProgressIndicator());
            final favTeams = teamSnap.data!.where((t) => favIds.contains(t.id)).toList();
            if (favTeams.isEmpty) {
              return const Center(child: Text('Ma haysatid koox aad ku darto favorites'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: favTeams.length,
              itemBuilder: (_, i) => _favTile(context, fs, uid!, favTeams[i]),
            );
          },
        );
      },
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
