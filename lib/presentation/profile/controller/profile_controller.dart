import 'dart:async';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:csv/csv.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/models/app_user.dart';
import '../../../data/models/tmdb_models/search_result.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/tmdb_repostiory.dart';
import '../../../data/repositories/watch_history_repository.dart';
import 'package:dio/dio.dart';
import '../../../data/models/tmdb_models/popular.dart';




class ProfileController extends GetxController {
  ProfileController({AuthRepository? authRepository})
      : _authRepository = authRepository ?? Get.find<AuthRepository>();

  final AuthRepository _authRepository;
  final TmdbRepository _tmdbRepository = Get.find<TmdbRepository>();
  final WatchHistoryRepository _watchHistoryRepository =
  Get.find<WatchHistoryRepository>();

  final user = Rxn<AppUser>();
  final isSigningOut = false.obs;
  final skipReasons = <String, int>{}.obs;
  final isImporting = false.obs;
  final importProgress = 0.0.obs;
  final importedCount = 0.obs;
  final skippedCount = 0.obs;
  final importStatus = ''.obs;

  final existingEpisodeCount = 0.obs;
  final missingEpisodeCount = 0.obs;
  final duplicateCsvCount = 0.obs;

  final missingEpisodesForImport = <Map<String, dynamic>>[].obs;

  final addedShows = <Map<String, dynamic>>[].obs;
  final isLoadingShows = false.obs;


  final addedMovies = <Map<String, dynamic>>[].obs;
  final isLoadingMovies = false.obs;

  final watchedEpisodeCount = 0.obs;

  StreamSubscription<int>? _episodeCountSubscription;

  @override
  void onInit() {
    super.onInit();

    user.value = _authRepository.currentUser;

    loadAddedShows();
    loadAddedMovies();

    listenToWatchedEpisodeCount();
  }

  Future<void> importTvTimeData() async {
    try {
      final pickedFile = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (pickedFile == null) return;

      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Import TV Time History'),
          content: const Text(
            'This will import your TV Time watch history into '
                'your existing WatchLog history. Episodes already '
                'saved will be skipped. Continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Import'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      isImporting.value = true;
      importProgress.value = 0;
      importedCount.value = 0;
      skippedCount.value = 0;
      skipReasons.clear();

      existingEpisodeCount.value = 0;
      missingEpisodeCount.value = 0;
      duplicateCsvCount.value = 0;
      missingEpisodesForImport.clear();

      importStatus.value = 'Reading CSV file...';

      final bytes = await pickedFile.readAsBytes();
      final csvText = utf8.decode(bytes, allowMalformed: true);
      final rows = const CsvDecoder().convert(csvText);

      if (rows.length < 2) {
        throw Exception('The CSV file contains no data.');
      }

      final headers = rows.first
          .map((value) => value.toString().trim().toLowerCase())
          .toList();

      final titleColumn = _findColumn(headers, [
        'title',
        'show',
        'show title',
        'name',
      ]);

      final seasonColumn = _findColumn(headers, [
        'season',
        'season number',
      ]);

      final episodeColumn = _findColumn(headers, [
        'episode',
        'episode number',
      ]);

      final watchedAtColumn = _findColumn(headers, [
        'watched_at',
        'watched at',
        'watched',
        'date watched',
      ]);

      if (titleColumn == -1 ||
          seasonColumn == -1 ||
          episodeColumn == -1) {
        throw Exception(
          'Could not find the required title, season, '
              'or episode columns.',
        );
      }

      final dataRows = rows.skip(1).toList();

      final episodesToImport = <Map<String, dynamic>>[];

      // Cache TMDB show IDs.
      final showCache = <String, int?>{};

      // Cache episode titles using the TMDB season number.
      final episodeCache = <String, Map<int, String>>{};

      // Dragon Ball Super TV Time-to-TMDB episode mapping.
      const dragonBallEpisodeOffsets = {
        1: 0,
        2: 14,
        3: 27,
        4: 46,
        5: 76,
      };

      const dragonBallSeasonEpisodeCounts = {
        1: 14,
        2: 13,
        3: 19,
        4: 30,
        5: 55,
      };

      const dragonBallSeasonOffsets = {
        1: 0,
        2: 13,
        3: 28,
        4: 68,
        5: 101,
        6: 132,
      };

      const dragonBallSeasonCounts = {
        1: 13,
        2: 15,
        3: 40,
        4: 33,
        5: 31,
        6: 21,
      };

      for (var i = 0; i < dataRows.length; i++) {
        final row = dataRows[i];

        try {
          final title = _cell(row, titleColumn);
          final seasonText = _cell(row, seasonColumn);
          final episodeText = _cell(row, episodeColumn);

          if (title.isEmpty ||
              seasonText.isEmpty ||
              episodeText.isEmpty) {
            _recordSkipped('Invalid CSV row');
            importProgress.value = (i + 1) / dataRows.length;
            continue;
          }

          final seasonNumber = int.tryParse(seasonText);
          final episodeNumber = int.tryParse(episodeText);

          if (seasonNumber == null ||
              episodeNumber == null ||
              seasonNumber < 1 ||
              episodeNumber < 1) {
            _recordSkipped('Invalid CSV row');
            importProgress.value = (i + 1) / dataRows.length;
            continue;
          }

          final normalizedTitle = _normalizeTitle(title);

          // Search for each show only once.
          if (!showCache.containsKey(normalizedTitle)) {
            importStatus.value = 'Finding $title...';

            final searchResults =
            await _tmdbRepository.searchTvShows(title);

            final matches = searchResults.results.where(
                  (show) =>
              _normalizeTitle(show.name) == normalizedTitle,
            ).toList();

            if (matches.length == 1) {
              showCache[normalizedTitle] = matches.first.id;
            } else {
              showCache[normalizedTitle] = null;
            }
          }

          final showId = showCache[normalizedTitle];

          if (showId == null) {
            _recordSkipped('Show not found or ambiguous');
            importProgress.value = (i + 1) / dataRows.length;
            continue;
          }

          // Start with the original TV Time numbering.
          var tmdbSeasonNumber = seasonNumber;
          var tmdbEpisodeNumber = episodeNumber;

          // Convert Dragon Ball Super numbering.
          if (normalizedTitle ==
              _normalizeTitle('Dragon Ball Super')) {
            final offset = dragonBallEpisodeOffsets[seasonNumber];
            final episodeCount =
            dragonBallSeasonEpisodeCounts[seasonNumber];

            if (offset == null ||
                episodeCount == null ||
                episodeNumber > episodeCount) {
              _recordSkipped(
                'Invalid Dragon Ball Super episode number',
              );
              importProgress.value = (i + 1) / dataRows.length;
              continue;
            }

            tmdbSeasonNumber = 1;
            tmdbEpisodeNumber = offset + episodeNumber;
          }

          // Convert Dragon Ball numbering.
          if (normalizedTitle == _normalizeTitle('Dragon Ball')) {
            final offset = dragonBallSeasonOffsets[seasonNumber];
            final episodeCount = dragonBallSeasonCounts[seasonNumber];

            if (offset == null ||
                episodeCount == null ||
                episodeNumber > episodeCount) {
              _recordSkipped('Invalid Dragon Ball episode number');
              importProgress.value = (i + 1) / dataRows.length;
              continue;
            }

            tmdbSeasonNumber = 1;
            tmdbEpisodeNumber = offset + episodeNumber;
          }

          // Attack on Titan: map the two finale specials to TMDB Season 0.
          if (normalizedTitle == _normalizeTitle('Attack on Titan') &&
              seasonNumber == 4 &&
              episodeNumber >= 29 &&
              episodeNumber <= 30) {
            tmdbSeasonNumber = 0;
            tmdbEpisodeNumber = episodeNumber == 29 ? 36 : 37;
          }

          debugPrint('===== EPISODE MAPPING =====');
          debugPrint('Show: $title');
          debugPrint('Original season: $seasonNumber');
          debugPrint('Original episode: $episodeNumber');
          debugPrint('TMDB season: $tmdbSeasonNumber');
          debugPrint('TMDB episode: $tmdbEpisodeNumber');

          final seasonKey = '${showId}_$tmdbSeasonNumber';

          // Fetch each TMDB season only once.
          if (!episodeCache.containsKey(seasonKey)) {
            importStatus.value = 'Fetching episodes for $title...';

            final details = await _tmdbRepository.getSeasonDetails(
              showId,
              tmdbSeasonNumber,
            );

            final seasonEpisodes =
                details['episodes'] as List? ?? [];

            final episodeTitles = <int, String>{};

            for (final item in seasonEpisodes) {
              final episode =
              Map<String, dynamic>.from(item as Map);

              final number = int.tryParse(
                episode['episode_number'].toString(),
              );

              final name = episode['name']?.toString();

              if (number != null &&
                  name != null &&
                  name.isNotEmpty) {
                episodeTitles[number] = name;
              }
            }

            episodeCache[seasonKey] = episodeTitles;
          }

          final episodeTitle =
          episodeCache[seasonKey]?[tmdbEpisodeNumber];

          if (episodeTitle == null) {
            debugPrint('===== EPISODE NOT FOUND =====');
            debugPrint('Show: $title');
            debugPrint('TMDB show ID: $showId');
            debugPrint('Original season: $seasonNumber');
            debugPrint('Original episode: $episodeNumber');
            debugPrint('TMDB season: $tmdbSeasonNumber');
            debugPrint('TMDB episode: $tmdbEpisodeNumber');
            debugPrint(
              'Available episode numbers: '
                  '${episodeCache[seasonKey]?.keys.toList()}',
            );

            if (normalizedTitle ==
                _normalizeTitle('Attack on Titan') &&
                seasonNumber == 4 &&
                episodeNumber > 28) {
              final specialsKey = '${showId}_0';

              if (!episodeCache.containsKey(specialsKey)) {
                final specialsDetails =
                await _tmdbRepository.getSeasonDetails(
                  showId,
                  0,
                );

                final specialsEpisodes =
                    specialsDetails['episodes'] as List? ?? [];

                final specialsTitles = <int, String>{};

                for (final item in specialsEpisodes) {
                  final episode =
                  Map<String, dynamic>.from(item as Map);

                  final number = int.tryParse(
                    episode['episode_number'].toString(),
                  );

                  final name = episode['name']?.toString();

                  if (number != null && name != null) {
                    specialsTitles[number] = name;
                  }
                }

                episodeCache[specialsKey] = specialsTitles;
              }

              debugPrint('===== ATTACK ON TITAN LATER SPECIALS =====');

              final specials = episodeCache[specialsKey]!;

              for (final entry in specials.entries) {
                if (entry.key >= 25) {
                  debugPrint('TMDB S0E${entry.key}: ${entry.value}');
                }
              }
            }

            _recordSkipped('Season or episode not found');
            importProgress.value = (i + 1) / dataRows.length;
            continue;
          }

          final watchedAtText = watchedAtColumn == -1
              ? ''
              : _cell(row, watchedAtColumn);

          final watchedAt = DateTime.tryParse(watchedAtText);

          // Store the converted TMDB numbering.
          episodesToImport.add({
            'showId': showId,
            'showTitle': title,
            'seasonNumber': tmdbSeasonNumber,
            'episodeNumber': tmdbEpisodeNumber,
            'episodeTitle': episodeTitle,
            'watchedAt': watchedAt ?? DateTime.now(),
          });
        } on DioException catch (e) {
          _recordSkipped('TMDB/API or processing error');

          debugPrint('===== TMDB API ERROR =====');
          debugPrint('CSV row: ${i + 2}');
          debugPrint('Error: ${e.message}');
          debugPrint('Request URL: ${e.requestOptions.uri}');
          debugPrint('Status code: ${e.response?.statusCode}');
          debugPrint('TMDB response: ${e.response?.data}');
        } catch (e) {
          _recordSkipped('TMDB/API or processing error');

          debugPrint('===== IMPORT ROW ERROR =====');
          debugPrint('CSV row: ${i + 2}');
          debugPrint('Error: $e');
        }

        importProgress.value = (i + 1) / dataRows.length;
      }

      // ==========================================
      // IMPORT INTO FIRESTORE
      // ==========================================

      importStatus.value = 'Preparing Firestore import...';

      if (episodesToImport.isEmpty) {
        throw Exception(
          'No valid episodes were matched with TMDB. '
              'Nothing was imported.',
        );
      }

      importStatus.value = 'Importing episodes into Firestore...';

      final result =
      await _watchHistoryRepository.importWatchedEpisodes(
        episodesToImport,
      );

      final written = result['writtenCount'] ?? 0;
      final alreadyExists = result['alreadyExistsCount'] ?? 0;
      final duplicates = result['duplicateCount'] ?? 0;

      importedCount.value = written;
      existingEpisodeCount.value = alreadyExists;
      duplicateCsvCount.value = duplicates;

      missingEpisodeCount.value = 0;
      missingEpisodesForImport.clear();

      importProgress.value = 1.0;
      importStatus.value = 'Import completed!';

      debugPrint('===== TV TIME IMPORT SUMMARY =====');
      debugPrint('CSV rows: ${dataRows.length}');
      debugPrint('Successfully matched: ${episodesToImport.length}');
      debugPrint('Newly imported: $written');
      debugPrint('Already in Firestore: $alreadyExists');
      debugPrint('Duplicate CSV entries: $duplicates');
      debugPrint('Skipped: ${skippedCount.value}');

      for (final entry in skipReasons.entries) {
        debugPrint('${entry.key}: ${entry.value}');
      }

      Get.snackbar(
        'Import completed',
        'Newly imported: $written\n'
            'Already saved: $alreadyExists\n'
            'Duplicates: $duplicates\n'
            'Skipped: ${skippedCount.value}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 8),
      );
    } catch (e) {
      importStatus.value = 'Import failed';

      debugPrint('===== TV TIME IMPORT FAILED =====');
      debugPrint('$e');

      Get.snackbar(
        'Import failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isImporting.value = false;
    }
  }

  Future<void> loadAddedShows() async {
    try {
      isLoadingShows.value = true;

      final shows = await _watchHistoryRepository.getAddedShows();

      addedShows.assignAll(shows);

      await loadShowPosters();
    } catch (e) {
      debugPrint('Error loading added shows: $e');
    } finally {
      isLoadingShows.value = false;
    }
  }

  Future<void> loadAddedMovies() async {
    try {
      isLoadingMovies.value = true;

      final movies = await _watchHistoryRepository.getAddedMovies();

      addedMovies.assignAll(movies);

      await loadMoviePosters();
    } catch (e) {
      debugPrint('Error loading added movies: $e');
    } finally {
      isLoadingMovies.value = false;
    }
  }

  Future<void> loadMoviePosters() async {
    for (var i = 0; i < addedMovies.length && i < 10; i++) {
      final movie = Map<String, dynamic>.from(addedMovies[i]);

      if (movie['posterPath'] != null) continue;

      try {
        final movieId = movie['movieId'] as int;

        final details =
        await _tmdbRepository.getMovieDetails(movieId);

        final posterPath = details['poster_path'];
        final backdropPath = details['backdrop_path'];

        if (posterPath != null || backdropPath != null) {
          await _watchHistoryRepository.updateMoviePosters(
            movieId: movieId,
            posterPath: posterPath,
            backdropPath: backdropPath,
          );

          movie['posterPath'] = posterPath;
          movie['backdropPath'] = backdropPath;

          addedMovies[i] = movie;
        }
      } catch (e) {
        debugPrint(
          'Could not load poster for ${movie['movieTitle']}: $e',
        );
      }
    }
  }

  Future<void> loadShowPosters() async {
    for (var i = 0; i < addedShows.length && i < 10; i++) {
      final show = Map<String, dynamic>.from(addedShows[i]);

      if (show['posterPath'] != null) continue;

      try {
        final showId = show['showId'] as int;

        final details = await _tmdbRepository.getTvShowDetails(showId);

        final posterPath = details['poster_path'];
        final backdropPath = details['backdrop_path'];

        if (posterPath != null || backdropPath != null) {
          await _watchHistoryRepository.updateShowPosters(
            showId: showId,
            posterPath: posterPath,
            backdropPath: backdropPath,
          );

          show['posterPath'] = posterPath;
          show['backdropPath'] = backdropPath;

          addedShows[i] = show;
        }
      } catch (e) {
        debugPrint('Could not load poster for ${show['showTitle']}: $e');
      }
    }
  }

  Future<void> migrateWatchedShows() async {
    try {
      isLoadingShows.value = true;

      final count =
      await _watchHistoryRepository.importWatchedShowsToLibrary();

      debugPrint('===== SHOW LIBRARY MIGRATION =====');
      debugPrint('New shows added: $count');
      debugPrint('==================================');

      await loadAddedShows();
    } catch (e) {
      debugPrint('Show library migration failed: $e');
    } finally {
      isLoadingShows.value = false;
    }
  }

  Future<void> openShowDetails(Map<String, dynamic> showData) async {
    try {
      final showId = showData['showId'] as int;

      // Fetch complete show information from TMDB.
      final details = await _tmdbRepository.getTvShowDetails(showId);

      // Convert TMDB response into the TvShow model.
      final show = TvShow.fromJson(details);

      // Navigate to the existing Show Details page.
      Get.toNamed(
        AppRoutes.showDetails,
        arguments: show,
      );
    } catch (e) {
      debugPrint('Failed to open show details: $e');

      Get.snackbar(
        'Error',
        'Unable to load show details.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> openMovieDetails(
      Map<String, dynamic> movieData,
      ) async {
    try {
      final movieId = movieData['movieId'] as int;

      final details =
      await _tmdbRepository.getMovieDetails(movieId);

      final movie = SearchResult.fromJson({
        ...details,
        'media_type': 'movie',
      });

      Get.toNamed(
        AppRoutes.movieDetails,
        arguments: movie,
      );
    } catch (e) {
      debugPrint('Failed to open movie details: $e');

      Get.snackbar(
        'Error',
        'Unable to load movie details.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  int _findColumn(List<String> headers, List<String> names) {
    return headers.indexWhere((header) => names.contains(header));
  }

  String _cell(List<dynamic> row, int index) {
    if (index < 0 || index >= row.length) return '';
    return row[index].toString().trim();
  }

  String _normalizeTitle(String title) {
    return title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  Future<void> signOut() async {
    if (isSigningOut.value) return;

    isSigningOut.value = true;

    try {
      await _authRepository.signOut();
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      Get.snackbar(
        'Sign out failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSigningOut.value = false;
    }
  }

  void _recordSkipped(String reason) {
    skippedCount.value++;

    skipReasons[reason] = (skipReasons[reason] ?? 0) + 1;
  }

  void listenToWatchedEpisodeCount() {
    _episodeCountSubscription?.cancel();

    _episodeCountSubscription =
        _watchHistoryRepository.watchWatchedEpisodeCount().listen(
              (count) {
            watchedEpisodeCount.value = count;
          },
          onError: (error) {
            debugPrint('Failed to load watched episode count: $error');
          },
        );
  }

  @override
  void onClose() {
    _episodeCountSubscription?.cancel();
    super.onClose();
  }

// Future<void> checkWatchedEpisodeCount() async {
//   final user = FirebaseAuth.instance.currentUser;
//
//   if (user == null) {
//     debugPrint('No signed-in user found.');
//     return;
//   }
//
//   final result = await FirebaseFirestore.instance
//       .collection('users')
//       .doc(user.uid)
//       .collection('watched_episodes')
//       .count()
//       .get();
//
//   debugPrint('TOTAL WATCHED EPISODES: ${result.count}');
// }
}