import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/match_model.dart';
import '../theme/app_theme.dart';

class AdminMatchesScreen extends StatelessWidget {
  const AdminMatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fs = FirestoreService();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maamul Ciyaaraha'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openEditSheet(context, fs, null),
          ),
        ],
      ),
      body: StreamBuilder<List<MatchModel>>(
        stream: fs.streamAllMatchesForAdmin(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final matches = snapshot.data!;
          if (matches.isEmpty) {
            return const Center(child: Text('Ma jiraan ciyaaro. Taabo + si aad u darto.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: matches.length,
            itemBuilder: (context, i) {
              final m = matches[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text('${m.teamAName} vs ${m.teamBName}'),
                  subtitle: Text(
                    '${m.league} • ${m.status} • ${m.isFree ? "FREE" : "Premium"} • ${m.streamEnabled ? "Stream ON" : "Stream OFF"}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  onTap: () => _openEditSheet(context, fs, m),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.danger),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Tirtir Ciyaarta?'),
                          content: Text('${m.teamAName} vs ${m.teamBName}'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Maya')),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Haa, Tirtir')),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await fs.deleteMatch(m.id);
                      }
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

  void _openEditSheet(BuildContext context, FirestoreService fs, MatchModel? match) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _MatchEditSheet(fs: fs, match: match),
    );
  }
}

class _MatchEditSheet extends StatefulWidget {
  final FirestoreService fs;
  final MatchModel? match;
  const _MatchEditSheet({required this.fs, required this.match});

  @override
  State<_MatchEditSheet> createState() => _MatchEditSheetState();
}

class _MatchEditSheetState extends State<_MatchEditSheet> {
  late TextEditingController _teamACtrl;
  late TextEditingController _teamBCtrl;
  late TextEditingController _leagueCtrl;
  late TextEditingController _hdUrlCtrl;
  late TextEditingController _sdUrlCtrl;
  late TextEditingController _scoreACtrl;
  late TextEditingController _scoreBCtrl;
  late String _sport;
  late String _status;
  late bool _isFree;
  late bool _streamEnabled;
  bool _saving = false;

  static const _sports = ['football', 'basketball', 'tennis', 'cricket', 'ufc', 'boxing'];
  static const _statuses = ['upcoming', 'live', 'finished'];

  @override
  void initState() {
    super.initState();
    final m = widget.match;
    _teamACtrl = TextEditingController(text: m?.teamAName ?? '');
    _teamBCtrl = TextEditingController(text: m?.teamBName ?? '');
    _leagueCtrl = TextEditingController(text: m?.league ?? '');
    _hdUrlCtrl = TextEditingController(text: m?.streamUrlHd ?? '');
    _sdUrlCtrl = TextEditingController(text: m?.streamUrlSd ?? '');
    _scoreACtrl = TextEditingController(text: (m?.scoreA ?? 0).toString());
    _scoreBCtrl = TextEditingController(text: (m?.scoreB ?? 0).toString());
    _sport = m?.sport ?? 'football';
    _status = m?.status ?? 'upcoming';
    _isFree = m?.isFree ?? false;
    _streamEnabled = m?.streamEnabled ?? false;
  }

  @override
  void dispose() {
    _teamACtrl.dispose();
    _teamBCtrl.dispose();
    _leagueCtrl.dispose();
    _hdUrlCtrl.dispose();
    _sdUrlCtrl.dispose();
    _scoreACtrl.dispose();
    _scoreBCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final data = {
      'sport': _sport,
      'league': _leagueCtrl.text.trim(),
      'teamAName': _teamACtrl.text.trim(),
      'teamBName': _teamBCtrl.text.trim(),
      'teamALogo': widget.match?.teamALogo ?? 'https://cdn-icons-png.flaticon.com/512/53/53283.png',
      'teamBLogo': widget.match?.teamBLogo ?? 'https://cdn-icons-png.flaticon.com/512/53/53283.png',
      'status': _status,
      'scoreA': int.tryParse(_scoreACtrl.text) ?? 0,
      'scoreB': int.tryParse(_scoreBCtrl.text) ?? 0,
      'isFree': _isFree,
      'streamEnabled': _streamEnabled,
      'streamUrlHd': _hdUrlCtrl.text.trim().isEmpty ? null : _hdUrlCtrl.text.trim(),
      'streamUrlSd': _sdUrlCtrl.text.trim().isEmpty ? null : _sdUrlCtrl.text.trim(),
    };

    try {
      if (widget.match != null) {
        await widget.fs.updateMatch(widget.match!.id, data);
      } else {
        data['startTime'] = DateTime.now().toIso8601String();
        data['reminderSent'] = true;
        await widget.fs.addMatch(data);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Khalad: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.match != null ? 'Wax ka beddel Ciyaarta' : 'Ku dar Ciyaar Cusub',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _sport,
              decoration: const InputDecoration(labelText: 'Sport'),
              items: _sports.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _sport = v!),
            ),
            const SizedBox(height: 10),
            TextField(controller: _leagueCtrl, decoration: const InputDecoration(labelText: 'League')),
            const SizedBox(height: 10),
            TextField(controller: _teamACtrl, decoration: const InputDecoration(labelText: 'Koox A')),
            const SizedBox(height: 10),
            TextField(controller: _teamBCtrl, decoration: const InputDecoration(labelText: 'Koox B')),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _scoreACtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Score A'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _scoreBCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Score B'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Xaalada'),
              items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: 16),
            const Text('Stream URLs', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _hdUrlCtrl,
              decoration: const InputDecoration(labelText: 'Stream URL (HD)', hintText: 'https://...'),
              maxLines: 2,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _sdUrlCtrl,
              decoration: const InputDecoration(labelText: 'Stream URL (SD)', hintText: 'https://...'),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Stream-ka Fural (Enable)'),
              value: _streamEnabled,
              onChanged: (v) => setState(() => _streamEnabled = v),
              activeColor: AppColors.primary,
            ),
            SwitchListTile(
              title: const Text('FREE (Premium looma baahna)'),
              value: _isFree,
              onChanged: (v) => setState(() => _isFree = v),
              activeColor: AppColors.primary,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Kaydi'),
            ),
          ],
        ),
      ),
    );
  }
}
