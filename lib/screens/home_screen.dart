import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../widgets/match_card.dart';
import '../theme/app_theme.dart';
import 'schedule_screen.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'premium_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  String _selectedSport = 'all';
  final _fs = FirestoreService();

  static const _sports = ['all', 'football', 'basketball', 'tennis', 'cricket', 'ufc', 'boxing'];

  final _pages = const [null, ScheduleScreen(), SearchScreen(), FavoritesScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _tab == 0 ? _buildHome() : _pages[_tab]!),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _tab = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Jadwalka'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Raadi'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHome() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('SportLiveTV', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.workspace_premium, color: AppColors.primary),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PremiumScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _sports.length,
              itemBuilder: (_, i) {
                final s = _sports[i];
                final selected = s == _selectedSport;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(s == 'all' ? 'Dhammaan' : s.toUpperCase()),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedSport = s),
                    selectedColor: AppColors.primary,
                  ),
                );
              },
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text('🔴 Live Hadda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
        StreamBuilder(
          stream: _fs.streamLiveMatches(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Ma jiraan ciyaaro live ah hadda', style: TextStyle(color: Colors.grey)),
                ),
              );
            }
            final matches = snapshot.data!;
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => MatchCard(match: matches[i]),
                childCount: matches.length,
              ),
            );
          },
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text('Ciyaaraha Soo Socda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
        StreamBuilder(
          stream: _fs.streamUpcomingMatches(sport: _selectedSport),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
            }
            final matches = snapshot.data!;
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => MatchCard(match: matches[i]),
                childCount: matches.length,
              ),
            );
          },
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}
