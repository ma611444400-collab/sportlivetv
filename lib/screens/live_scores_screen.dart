import 'dart:async';
import 'package:flutter/material.dart';
import '../models/live_score_model.dart';
import '../services/live_score_api.dart';
import '../theme/app_theme.dart';

class LiveScoresScreen extends StatefulWidget {
  const LiveScoresScreen({super.key});
  @override
  State<LiveScoresScreen> createState() => _LiveScoresScreenState();
}

class _LiveScoresScreenState extends State<LiveScoresScreen> {
  final _api = LiveScoreApi();
  List<LiveScoreModel> _matches = const [];
  Timer? _timer;
  bool _loading = true;
  String? _error;
  DateTime? _updatedAt;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _load(silent: true));
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent && mounted) setState(() { _loading = true; _error = null; });
    try {
      final matches = await _api.liveFixtures();
      if (!mounted) return;
      setState(() { _matches = matches; _loading = false; _error = null; _updatedAt = DateTime.now(); });
    } catch (error) {
      if (!mounted) return;
      setState(() { _loading = false; _error = error.toString(); });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Scores'),
        actions: [IconButton(onPressed: () => _load(), icon: const Icon(Icons.refresh))],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _matches.isEmpty) return const Center(child: CircularProgressIndicator());
    if (_error != null && _matches.isEmpty) {
      return ListView(children: [
        const SizedBox(height: 100),
        const Icon(Icons.sports_soccer, size: 56, color: AppColors.primary),
        const SizedBox(height: 16),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 28), child: Text(_error!, textAlign: TextAlign.center)),
        const SizedBox(height: 16),
        Center(child: ElevatedButton(onPressed: _load, child: const Text('Isku day mar kale'))),
      ]);
    }
    if (_matches.isEmpty) {
      return ListView(children: const [
        SizedBox(height: 140),
        Icon(Icons.event_busy, size: 56, color: Colors.grey),
        SizedBox(height: 16),
        Center(child: Text('Ma jiraan ciyaaro live ah hadda.')),
      ]);
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _matches.length + 1,
      itemBuilder: (_, index) {
        if (index == 0) return _updatedLabel();
        return _scoreCard(_matches[index - 1]);
      },
    );
  }

  Widget _updatedLabel() => Padding(
    padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
    child: Text(_updatedAt == null ? 'Live data' : 'La cusboonaysiiyay ${_updatedAt!.hour.toString().padLeft(2, '0')}:${_updatedAt!.minute.toString().padLeft(2, '0')}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
  );

  Widget _scoreCard(LiveScoreModel match) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _openEvents(match),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text('${match.league} · ${match.country}', style: const TextStyle(color: Colors.grey, fontSize: 12))), _statusPill(match)]),
          const SizedBox(height: 16),
          Row(children: [Expanded(child: _team(match.homeName, match.homeLogo)), Column(children: [Text('${match.homeGoals} - ${match.awayGoals}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)), Text(match.statusShort == 'HT' ? 'HT' : "${match.elapsed}'", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))]), Expanded(child: _team(match.awayName, match.awayLogo))]),
          if (match.events.isNotEmpty) ...[const Divider(height: 22), Text('${match.events.length} gool/event · taabo si aad u aragto', style: const TextStyle(color: Colors.grey, fontSize: 12))],
        ]),
      ),
    ),
  );

  Widget _team(String name, String logo) => Column(children: [
    logo.isEmpty ? const Icon(Icons.shield, size: 38) : Image.network(logo, width: 38, height: 38, errorBuilder: (_, __, ___) => const Icon(Icons.shield, size: 38)),
    const SizedBox(height: 6),
    Text(name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
  ]);

  Widget _statusPill(LiveScoreModel match) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.liveRed, borderRadius: BorderRadius.circular(8)), child: Text(match.statusShort, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)));

  Future<void> _openEvents(LiveScoreModel match) async {
    if (match.events.isNotEmpty) {
      _showEvents(match);
      return;
    }
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    try {
      final detailed = await _api.fixtureWithEvents(match.fixtureId);
      if (mounted) Navigator.of(context).pop();
      if (mounted) _showEvents(detailed ?? match);
    } catch (_) {
      if (mounted) Navigator.of(context).pop();
      if (mounted) _showEvents(match);
    }
  }

  void _showEvents(LiveScoreModel match) {
    showModalBottomSheet(context: context, builder: (_) => SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${match.homeName} ${match.homeGoals} - ${match.awayGoals} ${match.awayName}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 16), if (match.events.isEmpty) const Text('Weli event lama helin.') else ...match.events.map((e) => ListTile(leading: const Icon(Icons.sports_soccer, color: AppColors.primary), title: Text(e.player), subtitle: Text('${e.team} · ${e.elapsed} dakiiqo · ${e.detail}')))]))));
  }
}
