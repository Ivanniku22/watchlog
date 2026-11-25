
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/tmdb_models/popular.dart';
import '../../../data/repositories/tmdb_repostiory.dart';
import '../../../data/repositories/watch_history_repository.dart';

class ShowDetailsController extends GetxController {
  ShowDetailsController(this.show);

  final TvShow show;

  final TmdbRepository tmdbRepository = Get.find<TmdbRepository>();
  final WatchHistoryRepository watchHistoryRepository =
  Get.find<WatchHistoryRepository>();

  final Rxn<Map<String, dynamic>> showDetails =
  Rxn<Map<String, dynamic>>();

  final isLoadingDetails = true.obs;

  final loadedSeasonNumbers = <int>{}.obs;
  final loadingSeasonNumbers = <int>{}.obs;

  final RxList<Map<String, dynamic>> seasonDetails =
      <Map<String, dynamic>>[].obs;

  final isLoadingSeasons = true.obs;

  // Watchlist state
  final isShowAdded = false.obs;
  final isUpdatingWatchlist = false.obs;
  final isCheckingWatchlist = true.obs;

  @override
  void onInit() {
    super.onInit();

    fetchShowDetails();
    checkWatchlistStatus();
  }

  Future<void> fetchShowDetails() async {
    try {
      final details =
      await tmdbRepository.getTvShowDetails(show.id);

      showDetails.value = details;
    } catch (e) {
      debugPrint('Failed to fetch show details: $e');
    } finally {
      isLoadingDetails.value = false;
    }
  }

  Future<void> fetchSeasonDetails(int seasonNumber) async {
    if (loadedSeasonNumbers.contains(seasonNumber) ||
        loadingSeasonNumbers.contains(seasonNumber)) {
      return;
    }

    loadingSeasonNumbers.add(seasonNumber);

    try {
      final result = await tmdbRepository.getSeasonDetails(
        show.id,
        seasonNumber,
      );

      seasonDetails.removeWhere(
            (season) => season['season_number'] == seasonNumber,
      );

      seasonDetails.add(result);
      loadedSeasonNumbers.add(seasonNumber);
    } catch (e) {
      debugPrint('Failed to fetch season $seasonNumber: $e');
    } finally {
      loadingSeasonNumbers.remove(seasonNumber);
    }
  }

  // Check whether this show is already in the user's watchlist.
  Future<void> checkWatchlistStatus() async {
    try {
      isCheckingWatchlist.value = true;

      final added =
      await watchHistoryRepository.isShowAdded(show.id);

      isShowAdded.value = added;
    } catch (e) {
      debugPrint('Failed to check watchlist status: $e');
    } finally {
      isCheckingWatchlist.value = false;
    }
  }

  // Add show to watchlist.
  Future<void> addToWatchlist() async {
    if (isShowAdded.value || isUpdatingWatchlist.value) {
      return;
    }

    try {
      isUpdatingWatchlist.value = true;

      await watchHistoryRepository.addShow(
        showId: show.id,
        showTitle: show.name,
        posterPath: show.posterPath,
        backdropPath: show.backdropPath,
      );

      isShowAdded.value = true;

      Get.snackbar(
        'Added to Watchlist',
        '${show.name} has been added to your watchlist.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.isDarkMode
            ? const Color(0xFF252525)
            : const Color(0xFFFFFFFF),
        colorText: Get.isDarkMode
            ? Colors.white
            : const Color(0xFF222222),
        icon: const Icon(
          Icons.bookmark_added_rounded,
          color: Color(0xFFFFD700),
        ),
        borderRadius: 16,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        duration: const Duration(seconds: 3),
        boxShadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );
    } catch (e) {
      debugPrint('Failed to add show: $e');

      Get.snackbar(
        'Error',
        'Could not add this show. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.isDarkMode
            ? const Color(0xFF252525)
            : const Color(0xFFFFFFFF),
        colorText: Get.isDarkMode
            ? Colors.white
            : const Color(0xFF222222),
        icon: const Icon(
          Icons.error_outline_rounded,
          color: Color(0xFFE57373),
        ),
        borderRadius: 16,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        duration: const Duration(seconds: 3),
        boxShadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );
    } finally {
      isUpdatingWatchlist.value = false;
    }
  }

  // Remove show from watchlist without deleting watched episodes.
  Future<void> removeFromWatchlist() async {
    if (!isShowAdded.value || isUpdatingWatchlist.value) {
      return;
    }

    try {
      isUpdatingWatchlist.value = true;

      await watchHistoryRepository.removeShowFromWatchlist(show.id);

      isShowAdded.value = false;

      Get.snackbar(
        'Removed',
        '${show.name} has been removed from your watchlist.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.isDarkMode
            ? const Color(0xFF252525)
            : const Color(0xFFFFFFFF),
        colorText: Get.isDarkMode
            ? Colors.white
            : const Color(0xFF222222),
        icon: const Icon(
          Icons.bookmark_remove_rounded,
          color: Color(0xFFFFD700),
        ),
        borderRadius: 16,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        duration: const Duration(seconds: 3),
        boxShadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );
    } catch (e) {
      debugPrint('Failed to remove show: $e');

      Get.snackbar(
        'Error',
        'Could not remove this show. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.isDarkMode
            ? const Color(0xFF252525)
            : const Color(0xFFFFFFFF),
        colorText: Get.isDarkMode
            ? Colors.white
            : const Color(0xFF222222),
        icon: const Icon(
          Icons.error_outline_rounded,
          color: Color(0xFFE57373),
        ),
        borderRadius: 16,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        duration: const Duration(seconds: 3),
        boxShadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );
    } finally {
      isUpdatingWatchlist.value = false;
    }
  }
}
