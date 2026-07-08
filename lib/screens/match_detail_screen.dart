import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../services/firestore_service.dart';
import '../models/match_model.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import 'premium_screen.dart';

class MatchDetailScreen extends StatefulWidget {
  final String matchId;
  const MatchDetailScreen({super.key, required this.matchId});

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  final _fs = FirestoreService();
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _hd = true;

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _initPlayer(String url) async {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
    await _videoController!.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      autoPlay: true,
      looping: false,
      aspectRatio: 16 / 9,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return FutureBuilder<MatchModel?>(
      future: _fs.getMatch(widget.matchId),
      builder: (context, matchSnap) {
        if (!matchSnap.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final match = matchSnap.data!;

        return StreamBuilder<AppUser?>(
          stream: uid != null ? _fs.streamUser(uid) : const Stream.empty(),
          builder: (context, userSnap) {
            final user = userSnap.data;
            return Scaffold(
              appBar: AppBar(title: Text(match.league)),
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStreamArea(match, user),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text('${match.teamAName} vs ${match.teamBName}',
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              ),
                              if (match.isFree)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: AppColors.primary, borderRadius: BorderRadius.circular(6)),
                                  child: const Text('FREE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Xaalada: ${match.status}', style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 16),
                          const Text('Statistics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          if (match.stats != null)
                            ...match.stats!.entries.map((e) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [Text(e.key), Text('${e.value}')],
                                  ),
                                ))
                          else
                            const Text('Wali stats lama heli karo', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStreamArea(MatchModel match, AppUser? user) {
    final isLive = match.status == 'live';

    if (!isLive) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.black87,
          child: const Center(
            child: Text('Ciyaartu wali ma bilaaban', style: TextStyle(color: Colors.white70)),
          ),
        ),
      );
    }

    if (FirebaseAuth.instance.currentUser == null) {
      return _lockedOverlay('Fadlan gal si aad u daawato');
    }

    if (!match.streamEnabled || (match.streamUrlHd == null && match.streamUrlSd == null)) {
      return _lockedOverlay('Stream-kan wali lama heli karo');
    }

    // FREE matches (admin-flagged) skip the premium check entirely.
    // Everything else requires an active, non-expired Premium subscription.
    final canWatch = match.isFree || (user?.hasActivePremium ?? false);
    if (!canWatch) {
      return _lockedOverlay('Ciyaartan waa Premium — hel subscription si aad u daawato');
    }

    final url = _hd ? (match.streamUrlHd ?? match.streamUrlSd!) : (match.streamUrlSd ?? match.streamUrlHd!);
    if (_chewieController == null) {
      _initPlayer(url);
      return const AspectRatio(aspectRatio: 16 / 9, child: Center(child: CircularProgressIndicator()));
    }

    return Column(
      children: [
        AspectRatio(aspectRatio: 16 / 9, child: Chewie(controller: _chewieController!)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Text('Tayada: '),
              ChoiceChip(label: const Text('HD'), selected: _hd, onSelected: (_) => setState(() { _hd = true; _chewieController = null; })),
              const SizedBox(width: 8),
              ChoiceChip(label: const Text('SD'), selected: !_hd, onSelected: (_) => setState(() { _hd = false; _chewieController = null; })),
            ],
          ),
        ),
      ],
    );
  }

  Widget _lockedOverlay(String message) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black87,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, color: AppColors.primary, size: 40),
              const SizedBox(height: 8),
              Text(message, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PremiumScreen())),
                child: const Text('Hel Premium'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

