import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'firebase_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _google = GoogleSignIn();
  final FirebaseService _db = FirebaseService();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // ── Email / Password ──

  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user?.updateDisplayName(name);

    final user = UserModel(
      uid: cred.user!.uid,
      email: email,
      displayName: name,
    );
    await _db.createUserProfile(user);
    return user;
  }

  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _db.getUserProfile(cred.user!.uid);
  }

  // ── Google Sign-In ──

  Future<UserModel?> signInWithGoogle() async {
    final googleUser = await _google.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final cred = await _auth.signInWithCredential(credential);
    final uid = cred.user!.uid;

    final existing = await _db.getUserProfile(uid);
    if (existing != null) return existing;

    final user = UserModel(
      uid: uid,
      email: cred.user!.email ?? '',
      displayName: cred.user!.displayName,
      photoUrl: cred.user!.photoURL,
    );
    await _db.createUserProfile(user);
    return user;
  }

  // ── Sign out ──

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _google.signOut(),
    ]);
  }

  // ── Password reset ──

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
