import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../widgets/match_card.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fs = FirestoreService();
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Jadwalka Ciyaaraha', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ),
        Expanded(
          child: StreamBuilder(
            stream: fs.streamUpcomingMatches(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final matches = snapshot.data!;
              if (matches.isEmpty) return const Center(child: Text('Ma jiraan ciyaaro jadwal ah'));
              return ListView.builder(
                itemCount: matches.length,
                itemBuilder: (_, i) => MatchCard(match: matches[i]),
              );
            },
          ),
        ),
      ],
    );
  }
}
