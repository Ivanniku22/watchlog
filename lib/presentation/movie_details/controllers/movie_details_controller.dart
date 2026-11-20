import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/models/tmdb_models/search_result.dart';
import '../../../data/repositories/tmdb_repostiory.dart';
import '../../../data/repositories/watch_history_repository.dart';

class MovieDetailsController extends GetxController {
  MovieDetailsController(this.movie);

  final SearchResult movie;

  final TmdbRepository tmdbRepository = Get.find<TmdbRepository>();

  final WatchHistoryRepository watchHistoryRepository =
  Get.find<WatchHistoryRepository>();

  final isMovieAdded = false.obs;
  final isMovieWatched = false.obs;
  final isUpdatingWatchStatus = false.obs;

  final Rxn<Map<String, dynamic>> movieDetails =
  Rxn<Map<String, dynamic>>();

  final isLoadingDetails = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMovieDetails();
    loadMovieStatus();
  }

  Future<void> fetchMovieDetails() async {
    try {
      final details =
      await tmdbRepository.getMovieDetails(movie.id);

      movieDetails.value = details;
    } catch (e) {
      debugPrint('Failed to fetch movie details: $e');
    } finally {
      isLoadingDetails.value = false;
    }
  }

  Future<void> loadMovieStatus() async {
    try {
      final addedMovies =
      await watchHistoryRepository.getAddedMovies();

      isMovieAdded.value = addedMovies.any(
            (movie) => movie['movieId'] == this.movie.id,
      );

      isMovieWatched.value =
      await watchHistoryRepository.isMovieWatched(movie.id);
    } catch (e) {
      debugPrint('Failed to load movie status: $e');
    }
  }


  Future<void> toggleWatchedStatus() async {
    if (!isMovieAdded.value) {
      Get.snackbar(
        'Not in library',
        'Add this movie to your library first.',
      );
      return;
    }

    if (isUpdatingWatchStatus.value) return;

    isUpdatingWatchStatus.value = true;

    try {
      if (isMovieWatched.value) {
        await watchHistoryRepository.markMovieUnwatched(movie.id);
        isMovieWatched.value = false;
        _showWatchStatusSnackbar('Marked as unwatched');
      } else {
        await watchHistoryRepository.markMovieWatched(
          movieId: movie.id,
          movieTitle: movie.title,
        );
        isMovieWatched.value = true;
        _showWatchStatusSnackbar('Marked as watched');
      }
    } catch (e) {
      debugPrint('Failed to update movie watch status: $e');

      Get.snackbar(
        'Error',
        'Could not update watch status. Please try again.',
      );
    } finally {
      isUpdatingWatchStatus.value = false;
    }
  }


  void _showWatchStatusSnackbar(String message) {
    Get.snackbar(
      '',
      '',
      titleText: const SizedBox.shrink(),
      messageText: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.check,
              color: Colors.black,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF252525),
      borderRadius: 14,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      animationDuration: const Duration(milliseconds: 300),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

}