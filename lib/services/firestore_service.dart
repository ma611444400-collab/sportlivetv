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

  // ---------- ADMIN: MATCH MANAGEMENT ----------
  Stream<List<MatchModel>> streamAllMatchesForAdmin() {
    return _db
        .collection('matches')
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => MatchModel.fromMap(d.id, d.data())).toList());
  }

  Future<void> updateMatch(String matchId, Map<String, dynamic> data) {
    return _db.collection('matches').doc(matchId).update(data);
  }

  Future<void> deleteMatch(String matchId) {
    return _db.collection('matches').doc(matchId).delete();
  }

  Future<String> addMatch(Map<String, dynamic> data) async {
    final ref = await _db.collection('matches').add(data);
    return ref.id;
  }

  // ---------- PAYMENTS: EVC PLUS MANUAL VERIFICATION ----------
  /// User submits proof of an EVC Plus transfer they made. This creates a
  /// 'pending' record that only an admin can approve (see approvePayment).
  Future<void> submitPaymentRequest({
    required String uid,
    required String senderPhone,
    required String transactionId,
    required double amountUsd,
  }) {
    return _db.collection('payments').add({
      'uid': uid,
      'method': 'evc_plus',
      'senderPhone': senderPhone,
      'transactionId': transactionId,
      'amountUsd': amountUsd,
      'status': 'pending',
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Stream<List<Map<String, dynamic>>> streamPendingPayments() {
    return _db
        .collection('payments')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  /// Admin approves a payment: marks it approved AND activates premium
  /// for the user (30 days) in a single call.
  Future<void> approvePayment(String paymentId, String uid) async {
    final expires = DateTime.now().add(const Duration(days: 30));
    final batch = _db.batch();
    batch.update(_db.collection('payments').doc(paymentId), {'status': 'approved'});
    batch.update(_db.collection('users').doc(uid), {
      'isPremium': true,
      'premiumExpiresAt': expires.toIso8601String(),
    });
    await batch.commit();
  }

  Future<void> rejectPayment(String paymentId) {
    return _db.collection('payments').doc(paymentId).update({'status': 'rejected'});
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
