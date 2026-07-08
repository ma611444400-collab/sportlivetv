import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/match_model.dart';
import '../models/team_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------- MATCHES ----------
  Stream<List<MatchModel>> streamUpcomingMatches({String? sport}) {
    Query q = _db.collection('matches').orderBy('startTime');
    if (sport != null && sport != 'all') {
      q = q.where('sport', isEqualTo: sport);
    }
    return q.snapshots().map((snap) =>
        snap.docs.map((d) => MatchModel.fromMap(d.id, d.data() as Map<String, dynamic>)).toList());
  }

  Stream<List<MatchModel>> streamLiveMatches() {
    return _db
        .collection('matches')
        .where('status', isEqualTo: 'live')
        .snapshots()
        .map((snap) => snap.docs.map((d) => MatchModel.fromMap(d.id, d.data())).toList());
  }

  Future<MatchModel?> getMatch(String id) async {
    final doc = await _db.collection('matches').doc(id).get();
    if (!doc.exists) return null;
    return MatchModel.fromMap(doc.id, doc.data()!);
  }

  Future<List<MatchModel>> searchMatches(String query) async {
    final snap = await _db.collection('matches').get();
    final lower = query.toLowerCase();
    return snap.docs
        .map((d) => MatchModel.fromMap(d.id, d.data()))
        .where((m) =>
            m.teamAName.toLowerCase().contains(lower) ||
            m.teamBName.toLowerCase().contains(lower) ||
            m.league.toLowerCase().contains(lower))
        .toList();
  }

  // ---------- TEAMS / FAVORITES ----------
  Stream<List<TeamModel>> streamTeams({String? sport}) {
    Query q = _db.collection('teams');
    if (sport != null && sport != 'all') q = q.where('sport', isEqualTo: sport);
    return q.snapshots().map(
        (snap) => snap.docs.map((d) => TeamModel.fromMap(d.id, d.data() as Map<String, dynamic>)).toList());
  }

  Future<void> toggleFavorite(String uid, String teamId, bool isFavorite) {
    final ref = _db.collection('users').doc(uid);
    return ref.update({
      'favoriteTeamIds': isFavorite
          ? FieldValue.arrayUnion([teamId])
          : FieldValue.arrayRemove([teamId]),
    });
  }

  // ---------- USER ----------
  Stream<AppUser?> streamUser(String uid) {
    return _db.collection('users').doc(uid).snapshots().map(
        (doc) => doc.exists ? AppUser.fromMap(doc.id, doc.data()!) : null);
  }

  Future<void> updateLanguage(String uid, String lang) {
    return _db.collection('users').doc(uid).update({'preferredLanguage': lang});
  }
}
