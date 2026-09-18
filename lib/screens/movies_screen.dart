import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/movie_model.dart';
import '../services/tmdb_service.dart';
import '../theme/app_theme.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});
  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  final _tmdb = TmdbService();
  List<MovieModel> _movies = const [];
  Timer? _debounce;
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load({String? query}) async {
    setState(() { _loading = true; _error = null; });
    try {
      final movies = query == null || query.isEmpty ? await _tmdb.nowPlaying() : await _tmdb.search(query);
      if (mounted) setState(() { _movies = movies; _loading = false; });
    } catch (e) { if (mounted) setState(() { _loading = false; _error = e.toString(); }); }
  }

  @override
  void dispose() { _debounce?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Movies'), actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))]),
    body: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(12, 8, 12, 8), child: TextField(onChanged: (value) { _debounce?.cancel(); _debounce = Timer(const Duration(milliseconds: 500), () => _load(query: value.trim())); }, decoration: InputDecoration(hintText: 'Raadi filim...', prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))))),
      Expanded(child: _buildBody()),
    ]),
  );

  Widget _buildBody() {
    if (_loading && _movies.isEmpty) return const Center(child: CircularProgressIndicator());
    if (_error != null && _movies.isEmpty) return Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.movie_outlined, size: 52), const SizedBox(height: 12), Text(_error!, textAlign: TextAlign.center), const SizedBox(height: 12), ElevatedButton(onPressed: _load, child: const Text('Isku day mar kale'))])));
    if (_movies.isEmpty) return const Center(child: Text('Filim lama helin.'));
    return RefreshIndicator(onRefresh: _load, child: ListView.builder(padding: const EdgeInsets.all(12), itemCount: _movies.length + 1, itemBuilder: (_, i) { if (i == _movies.length) return const Padding(padding: EdgeInsets.all(20), child: Text('Data by TMDB · Not endorsed or certified by TMDB.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 11))); return _movieCard(_movies[i]); }));
  }

  Widget _movieCard(MovieModel movie) => Card(margin: const EdgeInsets.only(bottom: 14), clipBehavior: Clip.antiAlias, child: InkWell(onTap: () => _details(movie), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    SizedBox(width: 112, height: 168, child: movie.posterPath.isEmpty ? const ColoredBox(color: Colors.black12, child: Icon(Icons.movie, size: 40)) : Image.network(_tmdb.imageUrl(movie.posterPath), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.movie, size: 40))),
    Expanded(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(movie.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)), const SizedBox(height: 6), Text(movie.releaseDate.isEmpty ? 'Release date unknown' : movie.releaseDate, style: const TextStyle(color: Colors.grey, fontSize: 12)), const SizedBox(height: 6), Row(children: [const Icon(Icons.star, color: Colors.amber, size: 18), const SizedBox(width: 4), Text(movie.rating.toStringAsFixed(1))]), const SizedBox(height: 8), Text(movie.overview.isEmpty ? 'Faahfaahin lama helin.' : movie.overview, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, height: 1.25))]))),
  ])));

  Future<void> _details(MovieModel movie) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    MovieModel detailed = movie;
    try { detailed = await _tmdb.enrich(movie); } catch (_) {}
    if (mounted) Navigator.of(context).pop();
    if (!mounted) return;
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(detailed.title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text(detailed.overview.isEmpty ? 'Faahfaahin lama helin.' : detailed.overview, maxLines: 6, overflow: TextOverflow.ellipsis), const SizedBox(height: 16), Wrap(spacing: 10, runSpacing: 8, children: [if (detailed.trailerKey != null) ElevatedButton.icon(onPressed: () => launchUrl(Uri.parse('https://www.youtube.com/watch?v=${detailed.trailerKey}'), mode: LaunchMode.externalApplication), icon: const Icon(Icons.play_arrow), label: const Text('Daawo trailer')), if (detailed.officialWatchUrl != null) OutlinedButton.icon(onPressed: () => launchUrl(Uri.parse(detailed.officialWatchUrl!), mode: LaunchMode.externalApplication), icon: const Icon(Icons.ondemand_video), label: const Text('Daawo si rasmi ah'))])])));
  }
}
