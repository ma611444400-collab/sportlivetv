import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/global_sports_catalog.dart';
import '../models/team_model.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

class FavoriteTeamsScreen extends StatefulWidget {
  const FavoriteTeamsScreen({super.key});
  @override
  State<FavoriteTeamsScreen> createState() => _FavoriteTeamsScreenState();
}

class _FavoriteTeamsScreenState extends State<FavoriteTeamsScreen> {
  final _fs = FirestoreService();
  String _query = '';
  String _country = 'Dhammaan';
  final _countries = ['Dhammaan', 'England', 'Spain', 'Italy', 'Germany', 'France', 'Netherlands', 'Saudi Arabia'];

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Center(child: Text('Fadlan gal si aad u doorato kooxaha aad jeceshahay.'));
    return StreamBuilder(
      stream: _fs.streamUser(uid),
      builder: (context, snapshot) {
        final selected = snapshot.data?.favoriteTeamIds.toSet() ?? <String>{};
        final teams = GlobalSportsCatalog.teams.where((team) {
          final text = '${team.name} ${team.country}'.toLowerCase();
          return text.contains(_query) && (_country == 'Dhammaan' || team.country == _country);
        }).toList();
        return Scaffold(
          appBar: AppBar(title: const Text('Kooxaha aan jeclahay')),
          body: Column(children: [
            const Padding(padding: EdgeInsets.fromLTRB(16, 12, 16, 4), child: Align(alignment: Alignment.centerLeft, child: Text('Leagues caalami ah', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
            SizedBox(height: 58, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 16), scrollDirection: Axis.horizontal, itemCount: GlobalSportsCatalog.leagues.length, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (_, i) => _leagueChip(GlobalSportsCatalog.leagues[i]))),
            Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 4), child: TextField(onChanged: (value) => setState(() => _query = value.toLowerCase()), decoration: InputDecoration(hintText: 'Raadi koox...', prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))))),
            SizedBox(height: 46, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), scrollDirection: Axis.horizontal, itemCount: _countries.length, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (_, i) => ChoiceChip(label: Text(_countries[i]), selected: _country == _countries[i], onSelected: (_) => setState(() => _country = _countries[i])))),
            Expanded(child: teams.isEmpty ? const Center(child: Text('Koox lama helin.')) : ListView.builder(padding: const EdgeInsets.all(12), itemCount: teams.length, itemBuilder: (_, i) => _teamTile(uid, teams[i], selected.contains(teams[i].id)))),
          ]),
        );
      },
    );
  }

  Widget _leagueChip(GlobalLeague league) => ActionChip(avatar: Text(league.flag), label: Text(league.name), onPressed: () => setState(() => _query = ''));

  Widget _teamTile(String uid, TeamModel team, bool isSelected) => Card(child: ListTile(leading: Image.network(team.logoUrl, width: 42, height: 42, errorBuilder: (_, __, ___) => const Icon(Icons.shield, size: 38)), title: Text(team.name), subtitle: Text('${team.country} · Football'), trailing: IconButton(icon: Icon(isSelected ? Icons.favorite : Icons.favorite_border, color: isSelected ? Colors.red : Colors.grey), onPressed: () => _fs.toggleFavorite(uid, team.id, !isSelected))));
}
