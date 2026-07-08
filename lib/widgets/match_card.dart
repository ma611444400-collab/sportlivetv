import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/match_model.dart';
import '../theme/app_theme.dart';
import 'countdown_timer.dart';
import '../screens/match_detail_screen.dart';

class MatchCard extends StatelessWidget {
  final MatchModel match;
  const MatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final isLive = match.status == 'live';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => MatchDetailScreen(matchId: match.id)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(match.league, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const Spacer(),
                  if (isLive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.liveRed, borderRadius: BorderRadius.circular(6)),
                      child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _TeamLogo(url: match.teamALogo, name: match.teamAName),
                  Expanded(
                    child: Column(
                      children: [
                        if (isLive || match.status == 'finished')
                          Text('${match.scoreA} - ${match.scoreB}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
                        else
                          CountdownTimer(targetTime: match.startTime),
                      ],
                    ),
                  ),
                  _TeamLogo(url: match.teamBLogo, name: match.teamBName),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamLogo extends StatelessWidget {
  final String url;
  final String name;
  const _TeamLogo({required this.url, required this.name});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          ClipOval(
            child: CachedNetworkImage(
              imageUrl: url,
              width: 40,
              height: 40,
              errorWidget: (_, __, ___) => const Icon(Icons.shield, size: 40),
            ),
          ),
          const SizedBox(height: 4),
          Text(name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
