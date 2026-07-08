import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/match_model.dart';
import '../widgets/match_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _fs = FirestoreService();
  final _ctrl = TextEditingController();
  List<MatchModel> _results = [];
  bool _loading = false;

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _loading = true);
    final results = await _fs.searchMatches(q.trim());
    setState(() { _results = results; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _ctrl,
            onChanged: _search,
            decoration: InputDecoration(
              hintText: 'Raadi kooxo, league, ciyaaro...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        if (_loading) const CircularProgressIndicator(),
        Expanded(
          child: ListView.builder(
            itemCount: _results.length,
            itemBuilder: (_, i) => MatchCard(match: _results[i]),
          ),
        ),
      ],
    );
  }
}
