import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../data/repositories/watch_history_repository.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/models/tmdb_models/popular.dart';
import '../../../data/repositories/tmdb_repostiory.dart';


class AllShowsController extends GetxController {
  AllShowsController({
    required WatchHistoryRepository watchHistoryRepository,
  }) : _watchHistoryRepository = watchHistoryRepository;

  final WatchHistoryRepository _watchHistoryRepository;

  final shows = <Map<String, dynamic>>[].obs;

  final isLoading = false.obs;
  final hasMore = true.obs;
  final TmdbRepository _tmdbRepository = Get.find<TmdbRepository>();



  DocumentSnapshot<Map<String, dynamic>>? lastDocument;

  @override
  void onInit() {
    super.onInit();
    loadMoreShows();
  }

  Future<void> loadMoreShows() async {
    if (isLoading.value || !hasMore.value) return;

    try {
      isLoading.value = true;

      final snapshot = await _watchHistoryRepository.getAddedShowsPage(
        lastDocument: lastDocument,
        limit: 20,
      );

      if (snapshot.docs.isEmpty) {
        hasMore.value = false;
        return;
      }

      shows.addAll(
        snapshot.docs.map((doc) => doc.data()).toList(),
      );
      await loadMissingPosters();

      lastDocument = snapshot.docs.last;

      if (snapshot.docs.length < 20) {
        hasMore.value = false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load shows: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMissingPosters() async {
    for (int i = 0; i < shows.length; i++) {
      final show = Map<String, dynamic>.from(shows[i]);

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

          shows[i] = show;
        }
      } catch (e) {
        debugPrint('Could not load poster for ${show['showTitle']}: $e');
      }
    }
  }

  Future<void> openShowDetails(Map<String, dynamic> showData) async {
    try {
      final showId = showData['showId'] as int;

      final details = await _tmdbRepository.getTvShowDetails(showId);

      final show = TvShow.fromJson(details);

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
}