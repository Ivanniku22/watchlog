
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  Future<void> markEpisodeUnwatched({
    required int showId,
    required int seasonNumber,
    required int episodeNumber,
  }) async {
    final documentId = '${showId}_S${seasonNumber}_E$episodeNumber';

    await _watchedEpisodes.doc(documentId).delete();
  }



  Future<Map<String, dynamic>> compareWatchedEpisodes(
      List<Map<String, dynamic>> episodes,
      ) async {
    // Read the existing watch history. This method does not modify Firestore.
    final existingSnapshot = await _watchedEpisodes.get();

    final existingIds = existingSnapshot.docs
        .map((doc) => doc.id)
        .toSet();

    final seenCsvIds = <String>{};
    final missingEpisodes = <Map<String, dynamic>>[];

    var alreadyExistsCount = 0;
    var duplicateCsvCount = 0;

    for (final episode in episodes) {
      final documentId =
          '${episode['showId']}_S${episode['seasonNumber']}_E${episode['episodeNumber']}';

      // Ignore duplicate episode entries in the CSV.
      if (!seenCsvIds.add(documentId)) {
        duplicateCsvCount++;
        continue;
      }

      if (existingIds.contains(documentId)) {
        alreadyExistsCount++;
      } else {
        missingEpisodes.add(episode);
      }
    }

    return {
      'alreadyExistsCount': alreadyExistsCount,
      'missingEpisodes': missingEpisodes,
      'missingCount': missingEpisodes.length,
      'duplicateCsvCount': duplicateCsvCount,
      'uniqueCsvCount': seenCsvIds.length,
      'firestoreDocumentCount': existingSnapshot.docs.length,
    };
  }



  Future<int> importWatchedEpisodes(
      List<Map<String, dynamic>> episodes,
      ) async {
    const batchLimit = 500;
    var writtenCount = 0;

    for (var i = 0; i < episodes.length; i += batchLimit) {
      final chunk = episodes.skip(i).take(batchLimit).toList();

      final documentRefs = chunk.map((episode) {
        final documentId =
            '${episode['showId']}_S${episode['seasonNumber']}_E${episode['episodeNumber']}';

        return _watchedEpisodes.doc(documentId);
      }).toList();

      // Read existing documents before writing.
      final snapshots = await Future.wait(
        documentRefs.map((ref) => ref.get()),
      );

      final batch = _firestore.batch();
      var batchWriteCount = 0;

      for (var j = 0; j < chunk.length; j++) {
        final episode = chunk[j];
        final snapshot = snapshots[j];

        final watchedAt = Timestamp.fromDate(
          episode['watchedAt'] as DateTime,
        );

        final newData = {
          'showId': episode['showId'],
          'showTitle': episode['showTitle'],
          'seasonNumber': episode['seasonNumber'],
          'episodeNumber': episode['episodeNumber'],
          'episodeTitle': episode['episodeTitle'],
          'watchedAt': watchedAt,
        };

        // Skip existing documents.
        if (snapshot.exists) {
          continue;
        }

        batch.set(documentRefs[j], newData);
        batchWriteCount++;
      }

      if (batchWriteCount > 0) {
        await batch.commit();
        writtenCount += batchWriteCount;
      }

      debugPrint(
        'Import progress: ${i + chunk.length}/${episodes.length} '
            '| Newly saved: $writtenCount',
      );
    }

    return writtenCount;
  }

}
