
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

  CollectionReference<Map<String, dynamic>> get _addedShows {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('added_shows');
  }

  CollectionReference<Map<String, dynamic>> get _addedMovies {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('added_movies');
  }

  CollectionReference<Map<String, dynamic>> get _watchedMovies {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('watched_movies');
  }



  Future<void> addShow({
    required int showId,
    required String showTitle,
    String? posterPath,
    String? backdropPath,
  }) async {
    final data = <String, dynamic>{
      'showId': showId,
      'showTitle': showTitle,
      'addedAt': FieldValue.serverTimestamp(),
    };

    if (posterPath != null) {
      data['posterPath'] = posterPath;
    }

    if (backdropPath != null) {
      data['backdropPath'] = backdropPath;
    }

    await _addedShows
        .doc(showId.toString())
        .set(data, SetOptions(merge: true));
  }

  Future<List<Map<String, dynamic>>> getAddedShows() async {
    final snapshot = await _addedShows
        .orderBy('addedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Stream<List<Map<String, dynamic>>> watchAddedShows() {
    return _addedShows
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) => doc.data())
          .toList(),
    );
  }

  Stream<List<Map<String, dynamic>>> watchWatchedEpisodes() {
    return _watchedEpisodes
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) => doc.data())
          .toList(),
    );
  }

  Future<void> addMovie({
    required int movieId,
    required String movieTitle,
    String? posterPath,
    String? backdropPath,
    String? releaseDate,
  }) async {
    final data = <String, dynamic>{
      'movieId': movieId,
      'movieTitle': movieTitle,
      'addedAt': FieldValue.serverTimestamp(),
    };

    if (posterPath != null) data['posterPath'] = posterPath;
    if (backdropPath != null) data['backdropPath'] = backdropPath;
    if (releaseDate != null && releaseDate.isNotEmpty) {
      data['releaseDate'] = releaseDate;
    }

    await _addedMovies
        .doc(movieId.toString())
        .set(data, SetOptions(merge: true));
  }

  Stream<List<Map<String, dynamic>>> watchAddedMovies() {
    return _addedMovies
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) => doc.data())
          .toList(),
    );
  }

  Stream<List<Map<String, dynamic>>> watchWatchedMovies() {
    return _watchedMovies
        .orderBy('watchedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) => doc.data())
          .toList(),
    );
  }

  Future<bool> isMovieAdded(int movieId) async {
    final document = await _addedMovies.doc(movieId.toString()).get();
    return document.exists;
  }

  Future<void> removeMovieFromWatchlist(int movieId) async {
    await _addedMovies.doc(movieId.toString()).delete();
  }

  Future<void> updateMovieReleaseDate({
    required int movieId,
    required String releaseDate,
  }) async {
    await _addedMovies.doc(movieId.toString()).set({
      'releaseDate': releaseDate,
    }, SetOptions(merge: true));
  }

  Future<List<Map<String, dynamic>>> getAddedMovies() async {
    final snapshot = await _addedMovies
        .orderBy('addedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getAddedMoviesPage({
    DocumentSnapshot<Map<String, dynamic>>? lastDocument,
    int limit = 20,
  }) async {
    Query<Map<String, dynamic>> query = _addedMovies
        .orderBy('addedAt', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    return query.get();
  }

  Future<void> updateMoviePosters({
    required int movieId,
    String? posterPath,
    String? backdropPath,
  }) async {
    final data = <String, dynamic>{};

    if (posterPath != null) {
      data['posterPath'] = posterPath;
    }

    if (backdropPath != null) {
      data['backdropPath'] = backdropPath;
    }

    if (data.isEmpty) return;

    await _addedMovies
        .doc(movieId.toString())
        .set(data, SetOptions(merge: true));
  }

  Future<void> markMovieWatched({
    required int movieId,
    required String movieTitle,
    DateTime? watchedAt,
  }) async {
    await _watchedMovies.doc(movieId.toString()).set({
      'movieId': movieId,
      'movieTitle': movieTitle,
      'watchedAt': Timestamp.fromDate(
        watchedAt ?? DateTime.now(),
      ),
    }, SetOptions(merge: true));
  }

  Future<bool> isMovieWatched(int movieId) async {
    final document = await _watchedMovies
        .doc(movieId.toString())
        .get();

    return document.exists;
  }

  Future<void> markMovieUnwatched(int movieId) async {
    await _watchedMovies.doc(movieId.toString()).delete();
  }

  Future<List<Map<String, dynamic>>> getWatchedMovies() async {
    final snapshot = await _watchedMovies
        .orderBy('watchedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> removeMovie(int movieId) async {
    await _addedMovies.doc(movieId.toString()).delete();
    await _watchedMovies.doc(movieId.toString()).delete();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getAddedShowsPage({
    DocumentSnapshot<Map<String, dynamic>>? lastDocument,
    int limit = 20,
  }) async {
    Query<Map<String, dynamic>> query = _addedShows
        .orderBy('addedAt', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    return await query.get();
  }

  Future<int> importWatchedShowsToLibrary() async {
    // Read existing watched episodes.
    final episodesSnapshot = await _watchedEpisodes.get();

    // Group episodes by show ID.
    final Map<int, Map<String, dynamic>> uniqueShows = {};

    for (final episode in episodesSnapshot.docs) {
      final data = episode.data();
      final rawShowId = data['showId'];

      if (rawShowId is! num) continue;

      final showId = rawShowId.toInt();
      final watchedAt = data['watchedAt'];

      if (!uniqueShows.containsKey(showId)) {
        uniqueShows[showId] = {
          'showId': showId,
          'showTitle': data['showTitle'] ?? 'Unknown Show',
          'lastWatchedAt': watchedAt,
        };
      } else {
        final existingDate = uniqueShows[showId]!['lastWatchedAt'];

        if (watchedAt is Timestamp &&
            (existingDate is! Timestamp ||
                watchedAt.compareTo(existingDate) > 0)) {
          uniqueShows[showId]!['lastWatchedAt'] = watchedAt;
        }
      }
    }

    // Check which shows are already in the library.
    final existingShowsSnapshot = await _addedShows.get();

    final existingIds = existingShowsSnapshot.docs
        .map((doc) => doc.id)
        .toSet();

    // Only add shows that aren't already in the library.
    final showsToAdd = uniqueShows.entries
        .where((entry) => !existingIds.contains(entry.key.toString()))
        .toList();

    const batchLimit = 400;
    var importedCount = 0;

    for (var i = 0; i < showsToAdd.length; i += batchLimit) {
      final batch = _firestore.batch();

      final chunk = showsToAdd.skip(i).take(batchLimit);

      for (final entry in chunk) {
        final show = entry.value;

        batch.set(
          _addedShows.doc(entry.key.toString()),
          {
            'showId': show['showId'],
            'showTitle': show['showTitle'],
            'addedAt': FieldValue.serverTimestamp(),
            'lastWatchedAt': show['lastWatchedAt'],
          },
        );

        importedCount++;
      }

      await batch.commit();
    }

    return importedCount;
  }

  Future<void> updateShowPosters({
    required int showId,
    String? posterPath,
    String? backdropPath,
  }) async {
    final data = <String, dynamic>{};

    if (posterPath != null) {
      data['posterPath'] = posterPath;
    }

    if (backdropPath != null) {
      data['backdropPath'] = backdropPath;
    }

    if (data.isEmpty) return;

    await _addedShows
        .doc(showId.toString())
        .set(data, SetOptions(merge: true));
  }

  Future<void> removeShow(int showId) async {
    // Find all watched episodes belonging to this show.
    final episodesSnapshot = await _watchedEpisodes
        .where('showId', isEqualTo: showId)
        .get();

    // Remove the show from the library.
    await _addedShows.doc(showId.toString()).delete();

    // Delete episodes in batches of 400.
    const batchLimit = 400;
    final episodes = episodesSnapshot.docs;

    for (var i = 0; i < episodes.length; i += batchLimit) {
      final batch = _firestore.batch();

      final chunk = episodes.skip(i).take(batchLimit);

      for (final episode in chunk) {
        batch.delete(episode.reference);
      }

      await batch.commit();
    }
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




  Future<Map<String, int>> importWatchedEpisodes(
      List<Map<String, dynamic>> episodes,
      ) async {
    const batchLimit = 400;

    // Deduplicate episodes using their Firestore document IDs.
    final uniqueEpisodes = <String, Map<String, dynamic>>{};

    for (final episode in episodes) {
      final documentId =
          '${episode['showId']}_S${episode['seasonNumber']}_E${episode['episodeNumber']}';

      uniqueEpisodes.putIfAbsent(documentId, () => episode);
    }

    final episodeList = uniqueEpisodes.entries.toList();

    var writtenCount = 0;
    var alreadyExistsCount = 0;

    for (var i = 0; i < episodeList.length; i += batchLimit) {
      final chunk = episodeList.skip(i).take(batchLimit).toList();

      final documentRefs = chunk
          .map((entry) => _watchedEpisodes.doc(entry.key))
          .toList();

      // Read existing documents before writing.
      final snapshots = await Future.wait(
        documentRefs.map((ref) => ref.get()),
      );

      final batch = _firestore.batch();
      var batchWriteCount = 0;

      for (var j = 0; j < chunk.length; j++) {
        if (snapshots[j].exists) {
          alreadyExistsCount++;
          continue;
        }

        final episode = chunk[j].value;
        final watchedAt = episode['watchedAt'];

        if (watchedAt is! DateTime) {
          throw Exception(
            'Invalid watchedAt value for episode ${chunk[j].key}',
          );
        }


        batch.set(documentRefs[j], {
          'showId': episode['showId'],
          'showTitle': episode['showTitle'],
          'seasonNumber': episode['seasonNumber'],
          'episodeNumber': episode['episodeNumber'],
          'episodeTitle': episode['episodeTitle'],
          'watchedAt': Timestamp.fromDate(watchedAt),
        });

        batchWriteCount++;
      }

      if (batchWriteCount > 0) {
        await batch.commit();
        writtenCount += batchWriteCount;
      }

      debugPrint(
        'Import progress: ${i + chunk.length}/${episodeList.length} '
            '| Newly saved: $writtenCount '
            '| Already present: $alreadyExistsCount',
      );
    }

    return {
      'writtenCount': writtenCount,
      'alreadyExistsCount': alreadyExistsCount,
      'duplicateCount': episodes.length - uniqueEpisodes.length,
    };
  }

  Future<bool> isShowAdded(int showId) async {
    final document = await _addedShows.doc(showId.toString()).get();
    return document.exists;
  }

  Future<void> removeShowFromWatchlist(int showId) async {
    // Only remove the show from added_shows.
    // Keep all watched episode history intact.
    await _addedShows.doc(showId.toString()).delete();
  }

  Stream<int> watchWatchedEpisodeCount() {
    return _watchedEpisodes
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
