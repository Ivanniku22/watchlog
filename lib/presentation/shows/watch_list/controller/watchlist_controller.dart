
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../data/models/tmdb_models/popular.dart';
import '../../../../data/models/user_show.dart';
import '../../../../data/models/watchlist_models/next_episode.dart';
import '../../../../data/repositories/tmdb_repostiory.dart';
import '../../../../data/repositories/watch_history_repository.dart';

class WatchlistController extends GetxController {
  WatchlistController({
    required this.watchHistoryRepository,
    required this.tmdbRepository,
  });

  final WatchHistoryRepository watchHistoryRepository;
  final TmdbRepository tmdbRepository;

  final RxList<UserShow> myShows = <UserShow>[].obs;
  final RxList<Map<String, dynamic>> watchedEpisodes =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final Map<String, Map<String, dynamic>> _seasonsCache = {};
  StreamSubscription<List<Map<String, dynamic>>>? _showsSubscription;
  StreamSubscription<List<Map<String, dynamic>>>?
  _watchedEpisodesSubscription;
  bool _isRefreshing = false;
  bool _refreshRequested = false;
  final RxList<WatchlistEpisode> upcomingEpisodes =
      <WatchlistEpisode>[].obs;

  final RxList<WatchlistEpisode> currentlyWatching =
      <WatchlistEpisode>[].obs;

  final RxList<WatchlistEpisode> planToWatch =
      <WatchlistEpisode>[].obs;


  @override
  void onInit() {
    super.onInit();
    loadMyShows();
    loadWatchedEpisodes();
  }

  void loadMyShows() {
    isLoading.value = true;
    errorMessage.value = '';

    _showsSubscription =
        watchHistoryRepository.watchAddedShows().listen(
              (shows) async {
            final convertedShows = shows.map((data) {
              return UserShow.fromMap({
                'tmdbId': (data['showId'] as num).toInt(),
                'name': data['showTitle'] ?? 'Unknown Show',
                'posterPath': data['posterPath'] ?? '',
                'status': data['status'] ?? 'plan_to_watch',
                'addedAt': data['addedAt'],
              });
            }).toList();

            myShows.assignAll(convertedShows);

            debugPrint(
              'WATCHLIST: Loaded ${myShows.length} library shows',
            );

            await refreshWatchlist();
            isLoading.value = false;
          },
          onError: (error) {
            errorMessage.value = error.toString();
            isLoading.value = false;
          },
        );
  }

  void loadWatchedEpisodes() {
    _watchedEpisodesSubscription =
        watchHistoryRepository.watchWatchedEpisodes().listen(
              (episodes) async {
            watchedEpisodes.assignAll(episodes);
            debugPrint('WATCHLIST: Loaded ${episodes.length} watched episodes');
            await refreshWatchlist();
          },
          onError: (error) {
            errorMessage.value = error.toString();
          },
        );
  }

  bool isEpisodeWatched({
    required int showId,
    required int seasonNumber,
    required int episodeNumber,
  }) {
    return watchedEpisodes.any((episode) {
      return (episode['showId'] as num).toInt() == showId &&
          (episode['seasonNumber'] as num).toInt() == seasonNumber &&
          (episode['episodeNumber'] as num).toInt() == episodeNumber;
    });
  }


  Future<WatchlistEpisode?> findNextAvailableEpisode(
      UserShow show,
      ) async {
    final details = await tmdbRepository.getTvShowDetails(show.tmdbId);

    final seasons = (details['seasons'] as List<dynamic>? ?? [])
        .where((season) => (season['season_number'] as num) > 0)
        .toList()
      ..sort(
            (a, b) => (a['season_number'] as num)
            .compareTo(b['season_number'] as num),
      );

    for (final season in seasons) {
      final seasonNumber = (season['season_number'] as num).toInt();

      final cacheKey = '${show.tmdbId}_$seasonNumber';

      final seasonDetails = _seasonsCache[cacheKey] ??=
      await tmdbRepository.getSeasonDetails(
        show.tmdbId,
        seasonNumber,
      );

      final episodes =
          seasonDetails['episodes'] as List<dynamic>? ?? [];

      for (final episode in episodes) {
        final episodeNumber = (episode['episode_number'] as num).toInt();

        final watchlistEpisode = WatchlistEpisode.fromJson(
          showId: show.tmdbId,
          showTitle: show.name,
          seasonNumber: seasonNumber,
          json: Map<String, dynamic>.from(episode),
          posterPath: show.posterPath,
        );

        if (!watchlistEpisode.hasAired) continue;

        if (isEpisodeWatched(
          showId: show.tmdbId,
          seasonNumber: seasonNumber,
          episodeNumber: episodeNumber,
        )) {
          continue;
        }

        return watchlistEpisode;
      }
    }

    return null;
  }

  Future<WatchlistEpisode?> findNextUpcomingEpisode(
      UserShow show,
      ) async {
    final details = await tmdbRepository.getTvShowDetails(show.tmdbId);

    final seasons = (details['seasons'] as List<dynamic>? ?? [])
        .where((season) => (season['season_number'] as num) > 0)
        .toList()
      ..sort(
            (a, b) => (a['season_number'] as num)
            .compareTo(b['season_number'] as num),
      );

    WatchlistEpisode? nextEpisode;

    for (final season in seasons) {
      final seasonNumber = (season['season_number'] as num).toInt();
      final cacheKey = '${show.tmdbId}_$seasonNumber';

      final seasonDetails = _seasonsCache[cacheKey] ??=
      await tmdbRepository.getSeasonDetails(
        show.tmdbId,
        seasonNumber,
      );

      final episodes =
          seasonDetails['episodes'] as List<dynamic>? ?? [];

      for (final episode in episodes) {
        final watchlistEpisode = WatchlistEpisode.fromJson(
          showId: show.tmdbId,
          showTitle: show.name,
          seasonNumber: seasonNumber,
          json: Map<String, dynamic>.from(episode),
          posterPath: show.posterPath,
        );

        final airDate = watchlistEpisode.airDate;

        if (airDate == null || !airDate.isAfter(DateTime.now())) {
          continue;
        }

        if (nextEpisode == null ||
            airDate.isBefore(nextEpisode.airDate!)) {
          nextEpisode = watchlistEpisode;
        }
      }
    }

    return nextEpisode;
  }

  Future<void> markEpisodeWatched(WatchlistEpisode episode) async {
    await watchHistoryRepository.markEpisodeWatched(
      showId: episode.showId,
      showTitle: episode.showTitle,
      seasonNumber: episode.seasonNumber,
      episodeNumber: episode.episodeNumber,
      episodeTitle: episode.episodeTitle,
    );
  }

  Future<void> markEpisodeUnwatched(WatchlistEpisode episode) async {
    await watchHistoryRepository.markEpisodeUnwatched(
      showId: episode.showId,
      seasonNumber: episode.seasonNumber,
      episodeNumber: episode.episodeNumber,
    );
  }

  Future<void> openShowDetails(int showId) async {
    try {
      final showJson = await tmdbRepository.getTvShowDetails(showId);
      final show = TvShow.fromJson(showJson);

      Get.toNamed(
        AppRoutes.showDetails,
        arguments: show,
      );
    } catch (e) {
      errorMessage.value = 'Unable to open show details: $e';
    }
  }

  Future<void> classifyShow(UserShow show) async {
    // Remove any previous entry for this show.
    currentlyWatching.removeWhere(
          (episode) => episode.showId == show.tmdbId,
    );

    planToWatch.removeWhere(
          (episode) => episode.showId == show.tmdbId,
    );

    upcomingEpisodes.removeWhere(
          (episode) => episode.showId == show.tmdbId,
    );

    // Your existing classification logic starts here.
    final hasWatchedEpisodes = watchedEpisodes.any(
          (episode) =>
      (episode['showId'] as num).toInt() == show.tmdbId,
    );

    final nextAvailable = await findNextAvailableEpisode(show);

    if (nextAvailable != null) {
      if (hasWatchedEpisodes) {
        currentlyWatching.add(nextAvailable);
      } else {
        planToWatch.add(nextAvailable);
      }

      return;
    }

    final nextUpcoming = await findNextUpcomingEpisode(show);

    if (nextUpcoming != null) {
      upcomingEpisodes.add(nextUpcoming);
    }
  }

  Future<void> refreshWatchlist() async {
    if (_isRefreshing) {
      _refreshRequested = true;
      return;
    }

    _isRefreshing = true;

    try {
      do {
        _refreshRequested = false;

        currentlyWatching.clear();
        planToWatch.clear();
        upcomingEpisodes.clear();

        debugPrint(
          'WATCHLIST: Starting refresh for ${myShows.length} shows',
        );

        const batchSize = 5;

        for (var i = 0; i < myShows.length; i += batchSize) {
          final batch = myShows.skip(i).take(batchSize);

          await Future.wait(
            batch.map((show) => classifyShow(show)),
          );

          // Show the results as soon as the first batch finishes.
          if (i == 0) {
            isLoading.value = false;
          }

          debugPrint(
            'WATCHLIST: Processed '
                '${(i + batch.length).clamp(0, myShows.length)}'
                '/${myShows.length} shows',
          );
        }

        // Also handle an empty library.
        isLoading.value = false;

        debugPrint(
          'WATCHLIST: Refresh complete. '
              'Currently Watching: ${currentlyWatching.length}, '
              'Plan to Watch: ${planToWatch.length}, '
              'Upcoming: ${upcomingEpisodes.length}',
        );
      } while (_refreshRequested);
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> openEpisodeDetails(WatchlistEpisode selectedEpisode) async {
    try {
      final showJson = await tmdbRepository.getTvShowDetails(
        selectedEpisode.showId,
      );

      final show = TvShow.fromJson(showJson);

      final seasonJson = await tmdbRepository.getSeasonDetails(
        selectedEpisode.showId,
        selectedEpisode.seasonNumber,
      );

      final episodes = (seasonJson['episodes'] as List)
          .map((episode) {
        final episodeMap = Map<String, dynamic>.from(episode);

        episodeMap['season_number'] ??=
            selectedEpisode.seasonNumber;

        return episodeMap;
      })
          .toList();

      final selectedEpisodeJson = episodes.firstWhere(
            (episode) =>
        (episode['episode_number'] as num).toInt() ==
            selectedEpisode.episodeNumber,
      );

      Get.toNamed(
        AppRoutes.episodeDetails,
        arguments: {
          'show': show,
          'episodes': episodes,
          'episode': selectedEpisodeJson,
        },
      );
    } catch (e) {
      errorMessage.value = 'Unable to open episode details: $e';
    }
  }

  @override
  void onClose() {
    _showsSubscription?.cancel();
    _watchedEpisodesSubscription?.cancel();
    super.onClose();
  }
}
