
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../data/repositories/watch_history_repository.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/models/tmdb_models/search_result.dart';
import '../../../data/repositories/tmdb_repostiory.dart';

class AllMoviesController extends GetxController {
  AllMoviesController({
    required WatchHistoryRepository watchHistoryRepository,
  }) : _watchHistoryRepository = watchHistoryRepository;

  final WatchHistoryRepository _watchHistoryRepository;

  final movies = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final hasMore = true.obs;

  final TmdbRepository _tmdbRepository = Get.find<TmdbRepository>();

  DocumentSnapshot<Map<String, dynamic>>? lastDocument;

  @override
  void onInit() {
    super.onInit();
    loadMoreMovies();
  }

  Future<void> loadMoreMovies() async {
    if (isLoading.value || !hasMore.value) return;

    try {
      isLoading.value = true;

      final snapshot = await _watchHistoryRepository.getAddedMoviesPage(
        lastDocument: lastDocument,
        limit: 20,
      );

      if (snapshot.docs.isEmpty) {
        hasMore.value = false;
        return;
      }

      movies.addAll(snapshot.docs.map((doc) => doc.data()).toList());

      lastDocument = snapshot.docs.last;

      if (snapshot.docs.length < 20) {
        hasMore.value = false;
      }

      await loadMissingPosters();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load movies: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMissingPosters() async {
    for (int i = 0; i < movies.length; i++) {
      final movie = Map<String, dynamic>.from(movies[i]);

      if (movie['posterPath'] != null) continue;

      try {
        final movieId = movie['movieId'] as int;

        final details = await _tmdbRepository.getMovieDetails(movieId);

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

          movies[i] = movie;
        }
      } catch (e) {
        debugPrint(
          'Could not load poster for ${movie['movieTitle']}: $e',
        );
      }
    }
  }

  Future<void> openMovieDetails(Map<String, dynamic> movieData) async {
    try {
      final movieId = movieData['movieId'] as int;

      final details = await _tmdbRepository.getMovieDetails(movieId);

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
}
