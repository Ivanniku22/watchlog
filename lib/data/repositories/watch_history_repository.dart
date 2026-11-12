
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WatchHistoryRepository {
  WatchHistoryRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _watchedEpisodes {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('watched_episodes');
  }

  Future<void> markEpisodeWatched({
    required int showId,
    required String showTitle,
    required int seasonNumber,
    required int episodeNumber,
    required String episodeTitle,
    DateTime? watchedAt,
  }) async {
    final documentId = '${showId}_S${seasonNumber}_E$episodeNumber';

    await _watchedEpisodes.doc(documentId).set({
      'showId': showId,
      'showTitle': showTitle,
      'seasonNumber': seasonNumber,
      'episodeNumber': episodeNumber,
      'episodeTitle': episodeTitle,
      'watchedAt': Timestamp.fromDate(
        watchedAt ?? DateTime.now(),
      ),
    }, SetOptions(merge: true));
  }

  Future<bool> isEpisodeWatched({
    required int showId,
    required int seasonNumber,
    required int episodeNumber,
  }) async {
    final documentId = '${showId}_S${seasonNumber}_E$episodeNumber';

    final document = await _watchedEpisodes.doc(documentId).get();

    return document.exists;
  }
}
