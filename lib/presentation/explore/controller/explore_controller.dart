
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/tmdb_models/popular.dart';
import '../../../data/models/tmdb_models/search_result.dart';
import '../../../data/repositories/tmdb_repostiory.dart';
import '../../../data/repositories/watch_history_repository.dart';

class ExploreController extends GetxController {
  final TmdbRepository tmdbRepository = Get.find<TmdbRepository>();
  final WatchHistoryRepository watchHistoryRepository =
  Get.find<WatchHistoryRepository>();

  final addedShowIds = <int>{}.obs;
  final addedMovieIds = <int>{}.obs;

  // Existing data
  final popularTvShows = Rxn<Popular>();
  final topRatedTvShows = Rxn<Popular>();

  final isLoading = false.obs;
  final visibleCount = 6.obs;
  final currentPage = 1.obs;
  final isLoadingMore = false.obs;
  final topRatedVisibleCount = 6.obs;

  final popularAnime = Rxn<Popular>();
  final topRatedAnime = Rxn<Popular>();
  final newAnime = Rxn<Popular>();

  final popularAnimeVisibleCount = 6.obs;
  final topRatedAnimeVisibleCount = 6.obs;
  final newAnimeVisibleCount = 6.obs;

  // Search
  final searchTextController = TextEditingController();
  final searchQuery = ''.obs;
  final searchResults = Rxn<List<SearchResult>>();
  final isSearching = false.obs;
  final searchError = ''.obs;

  Timer? _searchDebounce;
  int _searchRequestId = 0;

  @override
  void onInit() {
    super.onInit();
    loadAddedShows();
    loadAddedMovies();
    fetchPopularTvShows();
    fetchTopRatedTvShows();
    fetchPopularAnime();
    fetchTopRatedAnime();
    fetchNewAnime();
  }

  void searchShows(String query) {
    final queryText = query.trim();

    searchQuery.value = queryText;

    _searchDebounce?.cancel();

    final requestId = ++_searchRequestId;

    if (queryText.isEmpty) {
      searchResults.value = null;
      isSearching.value = false;
      searchError.value = '';
      return;
    }

    searchResults.value = null;
    searchError.value = '';

    _searchDebounce = Timer(
      const Duration(milliseconds: 500),
          () async {
        try {
          isSearching.value = true;

          final results =
          await tmdbRepository.searchMulti(queryText);

          if (requestId != _searchRequestId) return;

          searchResults.value = results;
        } catch (e) {
          if (requestId != _searchRequestId) return;

          searchError.value =
          'Unable to search. Please try again.';

          debugPrint('Multi Search Error: $e');
        } finally {
          if (requestId == _searchRequestId) {
            isSearching.value = false;
          }
        }
      },
    );
  }

  Future<void> fetchPopularTvShows() async {
    try {
      isLoading.value = true;
      popularTvShows.value =
      await tmdbRepository.getPopularTvShows();
    } catch (e) {
      debugPrint('Error details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTopRatedTvShows() async {
    try {
      topRatedTvShows.value =
      await tmdbRepository.getTopRatedTvShows();
    } catch (e) {
      debugPrint('Error details: $e');
    }
  }

  Future<void> fetchPopularAnime() async {
    try {
      popularAnime.value =
      await tmdbRepository.getPopularAnime();
    } catch (e, stackTrace) {
      debugPrint('Popular Anime Error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> fetchTopRatedAnime() async {
    try {
      topRatedAnime.value =
      await tmdbRepository.getTopRatedAnime();
    } catch (e) {
      debugPrint('Error details: $e');
    }
  }

  Future<void> fetchNewAnime() async {
    try {
      newAnime.value =
      await tmdbRepository.getNewAnime();
    } catch (e) {
      debugPrint('Error details: $e');
    }
  }

  Future<void> loadAddedShows() async {
    try {
      final shows = await watchHistoryRepository.getAddedShows();

      addedShowIds.assignAll(
        shows.map((show) => show['showId'] as int),
      );
    } catch (e) {
      debugPrint('Error loading added shows: $e');
    }
  }

  Future<void> loadAddedMovies() async {
    try {
      final movies = await watchHistoryRepository.getAddedMovies();

      addedMovieIds.assignAll(
        movies.map((movie) => movie['movieId'] as int),
      );
    } catch (e) {
      debugPrint('Error loading added movies: $e');
    }
  }

  Future<void> addShow(TvShow show) async {
    if (addedShowIds.contains(show.id)) return;

    try {
      await watchHistoryRepository.addShow(
        showId: show.id,
        showTitle: show.name,
        posterPath: show.posterPath,
        backdropPath: show.backdropPath,
      );

      // Update the UI after Firestore confirms the save.
      addedShowIds.add(show.id);

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Added to your library',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    show.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF252525),
        borderRadius: 14,
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        animationDuration: const Duration(milliseconds: 300),
        isDismissible: true,
        forwardAnimationCurve: Curves.easeOutBack,
      );
    } catch (e) {
      debugPrint('Error adding show: $e');

      Get.snackbar(
        'Error',
        'Could not add ${show.name}. Please try again.',
      );
    }
  }


  Future<void> addSearchResult(SearchResult result) async {
    if (result.isMovie) {
      if (addedMovieIds.contains(result.id)) return;

      try {
        await watchHistoryRepository.addMovie(
          movieId: result.id,
          movieTitle: result.title,
          posterPath: result.posterPath,
          backdropPath: result.backdropPath,
        );

        addedMovieIds.add(result.id);
        _showAddedSnackbar(result.title, 'movie');
      } catch (e) {
        debugPrint('Error adding movie: $e');
        Get.snackbar('Error', 'Could not add ${result.title}.');
      }
    } else if (result.isTvShow) {
      if (addedShowIds.contains(result.id)) return;

      try {
        await watchHistoryRepository.addShow(
          showId: result.id,
          showTitle: result.title,
          posterPath: result.posterPath,
          backdropPath: result.backdropPath,
        );

        addedShowIds.add(result.id);
        _showAddedSnackbar(result.title, 'show');
      } catch (e) {
        debugPrint('Error adding show: $e');
        Get.snackbar('Error', 'Could not add ${result.title}.');
      }
    }
  }



  void _showAddedSnackbar(String title, String type) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Added to your library',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
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


  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchTextController.dispose();
    super.onClose();
  }
}
