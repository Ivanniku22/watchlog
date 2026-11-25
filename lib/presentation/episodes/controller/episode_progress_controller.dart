
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/watch_history_repository.dart';

class EpisodeProgressController extends GetxController {
  EpisodeProgressController()
      : _repository = Get.find<WatchHistoryRepository>();

  final WatchHistoryRepository _repository;

  final RxMap<String, bool> watchedEpisodes = <String, bool>{}.obs;

  final RxSet<int> markingSeasonNumbers = <int>{}.obs;

  String _episodeKey(int showId, int seasonNumber, int episodeNumber) {
    return '${showId}_S${seasonNumber}_E$episodeNumber';
  }

  bool isWatched({
    required int showId,
    required int seasonNumber,
    required int episodeNumber,
  }) {
    final key = _episodeKey(showId, seasonNumber, episodeNumber);
    return watchedEpisodes[key] ?? false;
  }

  Future<void> loadEpisodeStatus({
    required int showId,
    required int seasonNumber,
    required int episodeNumber,
  }) async {
    final key = _episodeKey(showId, seasonNumber, episodeNumber);

    try {
      final watched = await _repository.isEpisodeWatched(
        showId: showId,
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
      );

      // Don't overwrite a newer local state with an older database read.
      if (!watchedEpisodes.containsKey(key)) {
        watchedEpisodes[key] = watched;
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not load episode progress.');
    }
  }

  Future<void> toggleWatched({
    required int showId,
    required String showTitle,
    required int seasonNumber,
    required int episodeNumber,
    required String episodeTitle,
  }) async {
    final key = _episodeKey(showId, seasonNumber, episodeNumber);
    final previousValue = watchedEpisodes[key] ?? false;
    final newValue = !previousValue;

    // Update UI immediately.
    watchedEpisodes[key] = newValue;

    try {
      if (newValue) {
        await _repository.markEpisodeWatched(
          showId: showId,
          showTitle: showTitle,
          seasonNumber: seasonNumber,
          episodeNumber: episodeNumber,
          episodeTitle: episodeTitle,
        );
      } else {
        await _repository.markEpisodeUnwatched(
          showId: showId,
          seasonNumber: seasonNumber,
          episodeNumber: episodeNumber,
        );
      }
    } catch (e) {
      watchedEpisodes[key] = previousValue;
      Get.snackbar('Error', 'Could not update episode progress.');
    }
  }

  // Mark every episode in a season as watched.
  Future<void> markSeasonWatched({
    required int showId,
    required String showTitle,
    required int seasonNumber,
    required List<int> episodeNumbers,
    required Map<int, String> episodeTitles,
  }) async {
    if (markingSeasonNumbers.contains(seasonNumber)) return;

    if (episodeNumbers.isEmpty) return;

    markingSeasonNumbers.add(seasonNumber);

    final previousStates = <String, bool?>{};

    // Optimistically update all episode checkmarks.
    for (final episodeNumber in episodeNumbers.toSet()) {
      final key = _episodeKey(showId, seasonNumber, episodeNumber);

      previousStates[key] = watchedEpisodes.containsKey(key)
          ? watchedEpisodes[key]
          : null;

      watchedEpisodes[key] = true;
    }

    try {
      final markedCount = await _repository.markSeasonWatched(
        showId: showId,
        showTitle: showTitle,
        seasonNumber: seasonNumber,
        episodeNumbers: episodeNumbers,
        episodeTitles: episodeTitles,
      );

      if (markedCount == 0) {
        Get.snackbar(
          'Already Watched',
          'All episodes in this season are already watched.',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Season Updated',
          markedCount == 0
              ? 'All episodes in Season $seasonNumber were already watched.'
              : '$markedCount episodes in Season $seasonNumber marked as watched.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.isDarkMode
              ? const Color(0xFF252525)
              : const Color(0xFFFFFFFF),
          colorText: Get.isDarkMode
              ? Colors.white
              : const Color(0xFF222222),
          icon: const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFFFFD700),
          ),
          borderRadius: 16,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          duration: const Duration(seconds: 3),
          boxShadows: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        );
      }
    } catch (e) {
      // Restore the previous UI state if Firestore fails.
      for (final entry in previousStates.entries) {
        if (entry.value == null) {
          watchedEpisodes.remove(entry.key);
        } else {
          watchedEpisodes[entry.key] = entry.value!;
        }
      }

      Get.snackbar(
        'Error',
        'Could not mark the season as watched. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      markingSeasonNumbers.remove(seasonNumber);
    }
  }
}
