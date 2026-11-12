
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:csv/csv.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/models/app_user.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/tmdb_repostiory.dart';
import '../../../data/repositories/watch_history_repository.dart';

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
    if (isImporting.value) return;

    try {
      // Pick the CSV file.
      final pickedFile = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (pickedFile == null) return;

      // Start importing.
      isImporting.value = true;
      importProgress.value = 0;
      importedCount.value = 0;
      skippedCount.value = 0;
      importStatus.value = 'Reading CSV file...';

      // Read and decode the CSV.
      final bytes = await pickedFile.readAsBytes();

      final csvText = utf8.decode(
        bytes,
        allowMalformed: true,
      );

      final rows = CsvDecoder().convert(csvText);

      if (rows.length < 2) {
        throw Exception('The CSV file is empty or invalid.');
      }

      final headers = rows.first
          .map((value) => value.toString().trim().toLowerCase())
          .toList();

      final titleIndex = _findColumn(headers, ['title']);
      final seasonIndex = _findColumn(headers, ['season']);
      final episodeIndex = _findColumn(headers, ['episode']);
      final watchedAtIndex = _findColumn(
        headers,
        ['watched_at', 'watched at'],
      );

      if (titleIndex == -1 ||
          seasonIndex == -1 ||
          episodeIndex == -1) {
        throw Exception(
          'CSV must contain title, season and episode columns.',
        );
      }

      final dataRows = rows.skip(1).toList();

      // Cache TMDB results to avoid repeated API calls.
      final showCache = <String, int?>{};
      final episodeCache = <String, Map<int, String>>{};
      final episodesToImport = <Map<String, dynamic>>[];

      for (var i = 0; i < dataRows.length; i++) {
        final row = dataRows[i];

        try {
          final title = _cell(row, titleIndex);
          final seasonNumber = int.tryParse(_cell(row, seasonIndex));
          final episodeNumber = int.tryParse(_cell(row, episodeIndex));

          if (title.isEmpty ||
              seasonNumber == null ||
              episodeNumber == null) {
            skippedCount.value++;
            importProgress.value = (i + 1) / dataRows.length;
            continue;
          }

          // Search TMDB only once for each title.
          final titleKey = title.toLowerCase();

          if (!showCache.containsKey(titleKey)) {
            importStatus.value = 'Matching show: $title';

            final searchResults =
            await _tmdbRepository.searchTvShows(title);

            final exactMatches = searchResults.results
                .where(
                  (show) =>
              _normalizeTitle(show.name) ==
                  _normalizeTitle(title),
            )
                .toList();

            showCache[titleKey] =
            exactMatches.length == 1 ? exactMatches.first.id : null;
          }

          final showId = showCache[titleKey];

          if (showId == null) {
            skippedCount.value++;
            importProgress.value = (i + 1) / dataRows.length;
            continue;
          }

          // Fetch each season only once.
          final seasonKey = '${showId}_$seasonNumber';

          if (!episodeCache.containsKey(seasonKey)) {
            final details = await _tmdbRepository.getSeasonDetails(
              showId,
              seasonNumber,
            );

            final seasonEpisodes = details['episodes'] as List? ?? [];
            final episodeTitles = <int, String>{};

            for (final item in seasonEpisodes) {
              final episode = Map<String, dynamic>.from(item as Map);
              final number = episode['episode_number'] as int?;
              final name = episode['name']?.toString();

              if (number != null && name != null) {
                episodeTitles[number] = name;
              }
            }

            episodeCache[seasonKey] = episodeTitles;
          }

          final episodeTitle = episodeCache[seasonKey]?[episodeNumber];

          if (episodeTitle == null) {
            skippedCount.value++;
            importProgress.value = (i + 1) / dataRows.length;
            continue;
          }

          final watchedAt = watchedAtIndex == -1
              ? DateTime.now()
              : DateTime.tryParse(_cell(row, watchedAtIndex)) ??
              DateTime.now();

          episodesToImport.add({
            'showId': showId,
            'showTitle': title,
            'seasonNumber': seasonNumber,
            'episodeNumber': episodeNumber,
            'episodeTitle': episodeTitle,
            'watchedAt': watchedAt,
          });
        } catch (_) {
          skippedCount.value++;
        }

        importProgress.value = (i + 1) / dataRows.length;
      }

      // Save the matched episodes to Firestore.
      importStatus.value = 'Saving watched episodes...';

      if (episodesToImport.isNotEmpty) {
        await _watchHistoryRepository.importWatchedEpisodes(
          episodesToImport,
        );
      }

      importedCount.value = episodesToImport.length;
      importProgress.value = 1;
      importStatus.value = 'Import completed!';

      Get.snackbar(
        'Import completed',
        '${importedCount.value} episodes imported. '
            '${skippedCount.value} skipped.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      importStatus.value = 'Import failed';

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
}
