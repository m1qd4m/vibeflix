import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/movie.dart';
import '../models/user_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference get _users => _db.collection('users');

  DocumentReference? get _userDoc =>
      _uid != null ? _users.doc(_uid) : null;

  // ── User profile ──

  Future<void> createUserProfile(UserModel user) async {
    await _users.doc(user.uid).set(user.toFirestore(), SetOptions(merge: true));
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc.data() as Map<String, dynamic>, uid);
  }

  Stream<UserModel?> userProfileStream(String uid) {
    return _users.doc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      return UserModel.fromFirestore(snap.data() as Map<String, dynamic>, uid);
    });
  }

  /// Updates the display name in both Firebase Auth and Firestore.
  Future<void> updateDisplayName(String name) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.updateDisplayName(name);
    if (_userDoc != null) {
      await _userDoc!.update({'displayName': name});
    }
  }

  // ── Watch history ──

  Future<void> addToWatchHistory(Movie movie) async {
    if (_userDoc == null) return;
    await _userDoc!.collection('watchHistory').doc('${movie.id}').set({
      ...movie.toFirestore(),
      'watchedAt': FieldValue.serverTimestamp(),
    });
    await _userDoc!.update({
      'watchHistory': FieldValue.arrayUnion([movie.id]),
    });
  }

  Future<List<Movie>> getWatchHistory({int limit = 20}) async {
    if (_userDoc == null) return [];
    final snap = await _userDoc!
        .collection('watchHistory')
        .orderBy('watchedAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs
        .map((d) => Movie.fromFirestore(d.data()))
        .toList();
  }

  Stream<List<Movie>> watchHistoryStream() {
    if (_userDoc == null) return Stream.value([]);
    return _userDoc!
        .collection('watchHistory')
        .orderBy('watchedAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Movie.fromFirestore(d.data())).toList());
  }

  // ── Watchlist ──

  Future<void> addToWatchlist(Movie movie) async {
    if (_userDoc == null) return;
    await _userDoc!.collection('watchlist').doc('${movie.id}').set(
          movie.toFirestore(),
        );
    await _userDoc!.update({
      'watchlist': FieldValue.arrayUnion([movie.id]),
    });
  }

  Future<void> removeFromWatchlist(int movieId) async {
    if (_userDoc == null) return;
    await _userDoc!.collection('watchlist').doc('$movieId').delete();
    await _userDoc!.update({
      'watchlist': FieldValue.arrayRemove([movieId]),
    });
  }

  Future<bool> isInWatchlist(int movieId) async {
    if (_userDoc == null) return false;
    final doc =
        await _userDoc!.collection('watchlist').doc('$movieId').get();
    return doc.exists;
  }

  Stream<List<Movie>> watchlistStream() {
    if (_userDoc == null) return Stream.value([]);
    return _userDoc!
        .collection('watchlist')
        .orderBy('watchedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Movie.fromFirestore(d.data())).toList());
  }

  // ── Personalized recommendations ──

  Future<List<int>> getWatchHistoryGenreIds() async {
    if (_userDoc == null) return [];
    final snap = await _userDoc!
        .collection('watchHistory')
        .orderBy('watchedAt', descending: true)
        .limit(10)
        .get();

    final allGenreIds = <int>[];
    for (final doc in snap.docs) {
      final ids = (doc.data()['genreIds'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [];
      allGenreIds.addAll(ids);
    }

    // Count frequency
    final freq = <int, int>{};
    for (final id in allGenreIds) {
      freq[id] = (freq[id] ?? 0) + 1;
    }
    final sorted = freq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).map((e) => e.key).toList();
  }
}
