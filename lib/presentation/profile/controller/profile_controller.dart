
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:csv/csv.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/models/app_user.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/tmdb_repostiory.dart';
import '../../../data/repositories/watch_history_repository.dart';
import 'package:dio/dio.dart';


class ProfileController extends GetxController {
  ProfileController({AuthRepository? authRepository})
      : _authRepository =
      authRepository ?? Get.find<AuthRepository>();

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

  @override
  void onInit() {
    super.onInit();
    user.value = _authRepository.currentUser;
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
            'This will import your watched episodes into your '
                'WatchLog account. Continue?',
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
          'Could not find the required title, season, or episode columns.',
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

          // Convert Dragon Ball Super numbering BEFORE
          // creating the season key or making the API request.
          if (normalizedTitle ==
              _normalizeTitle('Dragon Ball Super')) {
            final offset =
            dragonBallEpisodeOffsets[seasonNumber];

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

          debugPrint('===== EPISODE MAPPING =====');
          debugPrint('Show: $title');
          debugPrint('Original season: $seasonNumber');
          debugPrint('Original episode: $episodeNumber');
          debugPrint('TMDB season: $tmdbSeasonNumber');
          debugPrint('TMDB episode: $tmdbEpisodeNumber');

          // IMPORTANT: This key uses the converted TMDB season.
          final seasonKey = '${showId}_$tmdbSeasonNumber';

          // Fetch each TMDB season only once.
          if (!episodeCache.containsKey(seasonKey)) {
            importStatus.value = 'Fetching episodes for $title...';

            debugPrint('===== TMDB SEASON REQUEST =====');
            debugPrint('Show title: $title');
            debugPrint('TMDB show ID: $showId');
            debugPrint('TMDB season number: $tmdbSeasonNumber');

            final details =
            await _tmdbRepository.getSeasonDetails(
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

          // Use the converted TMDB episode number.
          final episodeTitle =
          episodeCache[seasonKey]?[tmdbEpisodeNumber];

          if (episodeTitle == null) {
            _recordSkipped('Season or episode not found');
            importProgress.value = (i + 1) / dataRows.length;
            continue;
          }

          final watchedAtText = watchedAtColumn == -1
              ? ''
              : _cell(row, watchedAtColumn);

          final watchedAt = DateTime.tryParse(watchedAtText);

          // Save the converted TMDB numbering.
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

      // Save successfully matched episodes.
      importStatus.value = 'Saving episodes...';

      if (episodesToImport.isNotEmpty) {
        await _watchHistoryRepository.importWatchedEpisodes(
          episodesToImport,
        );
      }

      importedCount.value = episodesToImport.length;
      importStatus.value = 'Import completed!';

      Get.snackbar(
        'Import completed',
        '${importedCount.value} episodes imported, '
            '${skippedCount.value} skipped.',
        snackPosition: SnackPosition.BOTTOM,
      );

      debugPrint('===== TV TIME IMPORT SUMMARY =====');
      debugPrint('Imported: ${importedCount.value}');
      debugPrint('Skipped: ${skippedCount.value}');

      for (final entry in skipReasons.entries) {
        debugPrint('${entry.key}: ${entry.value}');
      }
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





  int _findColumn(List<String> headers, List<String> names) {
    return headers.indexWhere((header) => names.contains(header));
  }

  String _cell(List<dynamic> row, int index) {
    if (index < 0 || index >= row.length) return '';
    return row[index].toString().trim();
  }

  String _normalizeTitle(String title) {
    return title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
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
}
