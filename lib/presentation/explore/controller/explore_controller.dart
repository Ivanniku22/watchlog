
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/tmdb_models/popular.dart';
import '../../../data/repositories/tmdb_repostiory.dart';

class ExploreController extends GetxController {
  final TmdbRepository tmdbRepository = Get.find<TmdbRepository>();

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
  final searchResults = Rxn<Popular>();
  final isSearching = false.obs;
  final searchError = ''.obs;

  Timer? _searchDebounce;
  int _searchRequestId = 0;

  @override
  void onInit() {
    super.onInit();

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

    // Invalidate any previous request immediately.
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
          await tmdbRepository.searchTvShows(queryText);

          if (requestId != _searchRequestId) return;

          searchResults.value = results;
        } catch (e) {
          if (requestId != _searchRequestId) return;

          searchError.value =
          'Unable to search shows. Please try again.';

          debugPrint('TV Show Search Error: $e');
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

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchTextController.dispose();
    super.onClose();
  }
}
