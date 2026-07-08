import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Handles sign up, login, phone OTP, and password reset.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ---------- EMAIL ----------
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _createUserDoc(cred.user!.uid, email: email, displayName: displayName);
    await cred.user!.sendEmailVerification();
    return cred;
  }

  Future<UserCredential> loginWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  // ---------- PHONE OTP ----------
  /// Starts phone verification. [onCodeSent] gives you the verificationId
  /// to pass into [verifyOtp].
  Future<void> startPhoneVerification({
    required String phoneNumber, // e.g. +2526xxxxxxxx
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? 'Khalad ayaa dhacay');
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<UserCredential> verifyOtp({
    required String verificationId,
    required String smsCode,
    String? displayName,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final result = await _auth.signInWithCredential(credential);
    // Create user doc if first time
    final doc = await _db.collection('users').doc(result.user!.uid).get();
    if (!doc.exists) {
      await _createUserDoc(
        result.user!.uid,
        phone: result.user!.phoneNumber,
        displayName: displayName ?? 'Isticmaale',
      );
    }
    return result;
  }

  Future<void> _createUserDoc(String uid, {String? email, String? phone, required String displayName}) {
    final user = AppUser(
      uid: uid,
      email: email,
      phone: phone,
      displayName: displayName,
      createdAt: DateTime.now(),
    );
    return _db.collection('users').doc(uid).set(user.toMap());
  }

  Future<void> signOut() => _auth.signOut();
}
