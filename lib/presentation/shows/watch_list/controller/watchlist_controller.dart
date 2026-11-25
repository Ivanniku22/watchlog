
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../data/models/tmdb_models/popular.dart';
import '../../../../data/models/user_show.dart';
import '../../../../data/models/watchlist_models/next_episode.dart';
import '../../../../data/repositories/tmdb_repostiory.dart';
import '../../../../data/repositories/watch_history_repository.dart';


class _ShowClassification {
  final WatchlistEpisode? currentlyWatching;
  final WatchlistEpisode? planToWatch;
  final WatchlistEpisode? upcoming;

  const _ShowClassification({
    this.currentlyWatching,
    this.planToWatch,
    this.upcoming,
  });
}


class WatchlistController extends GetxController {
  WatchlistController({
    required this.watchHistoryRepository,
    required this.tmdbRepository,
  });

  final WatchHistoryRepository watchHistoryRepository;
  final TmdbRepository tmdbRepository;

  // --------------------------------------------------
  // REACTIVE DATA
  // --------------------------------------------------

  final RxList<UserShow> myShows = <UserShow>[].obs;

  final RxList<WatchlistEpisode> currentlyWatching =
      <WatchlistEpisode>[].obs;

  final RxList<WatchlistEpisode> planToWatch =
      <WatchlistEpisode>[].obs;

  final RxList<WatchlistEpisode> upcomingEpisodes =
      <WatchlistEpisode>[].obs;

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  // --------------------------------------------------
  // WATCHED EPISODE LOOKUP
  // --------------------------------------------------

  final Set<String> _watchedEpisodeKeys = {};
  final Set<int> _showsWithWatchedEpisodes = {};

  // Cached TMDB responses
  final Map<int, Map<String, dynamic>> _showDetailsCache = {};
  final Map<String, Map<String, dynamic>> _seasonsCache = {};

// Cache timestamps
  final Map<int, DateTime> _showDetailsCacheTime = {};
  final Map<String, DateTime> _seasonDetailsCacheTime = {};

// Cache lifetime
  static const Duration _cacheDuration = Duration(hours: 6);

  // --------------------------------------------------
  // FIRESTORE SUBSCRIPTIONS
  // --------------------------------------------------

  StreamSubscription<List<Map<String, dynamic>>>? _showsSubscription;

  StreamSubscription<List<Map<String, dynamic>>>?
  _watchedEpisodesSubscription;

  // --------------------------------------------------
  // LOADING COORDINATION
  // --------------------------------------------------

  bool _hasLoadedShows = false;
  bool _hasLoadedWatchedEpisodes = false;

  // --------------------------------------------------
  // REFRESH COORDINATION
  // --------------------------------------------------

  bool _isRefreshing = false;
  bool _refreshRequested = false;

  bool _isRefreshingAffectedShows = false;

  final Set<int> _pendingShowRefreshIds = {};

  // In-progress TMDB requests
  final Map<int, Future<Map<String, dynamic>>> _showDetailsRequests = {};

  final Map<String, Future<Map<String, dynamic>>> _seasonDetailsRequests = {};

  // --------------------------------------------------
  // INIT
  // --------------------------------------------------

  @override
  void onInit() {
    super.onInit();

    loadMyShows();
    loadWatchedEpisodes();
  }

  // --------------------------------------------------
  // EPISODE KEY
  // --------------------------------------------------

  String _episodeKey(
      int showId,
      int seasonNumber,
      int episodeNumber,
      ) {
    return '${showId}_S${seasonNumber}_E$episodeNumber';
  }

  // --------------------------------------------------
  // TMDB CACHING
  // --------------------------------------------------

  Future<Map<String, dynamic>> getCachedShowDetails(int showId) async {
    final cachedTime = _showDetailsCacheTime[showId];

    // Return cached data if it hasn't expired.
    if (_showDetailsCache.containsKey(showId) &&
        cachedTime != null &&
        DateTime.now().difference(cachedTime) < _cacheDuration) {
      return _showDetailsCache[showId]!;
    }

    // Reuse an ongoing request for this show.
    if (_showDetailsRequests.containsKey(showId)) {
      return _showDetailsRequests[showId]!;
    }

    final request = tmdbRepository.getTvShowDetails(showId);
    _showDetailsRequests[showId] = request;

    try {
      final details = await request;

      _showDetailsCache[showId] = details;
      _showDetailsCacheTime[showId] = DateTime.now();

      return details;
    } finally {
      _showDetailsRequests.remove(showId);
    }
  }

  Future<Map<String, dynamic>> getCachedSeasonDetails(
      int showId,
      int seasonNumber,
      ) async {
    final cacheKey = '${showId}_$seasonNumber';
    final cachedTime = _seasonDetailsCacheTime[cacheKey];

    // Return cached data if it hasn't expired.
    if (_seasonsCache.containsKey(cacheKey) &&
        cachedTime != null &&
        DateTime.now().difference(cachedTime) < _cacheDuration) {
      return _seasonsCache[cacheKey]!;
    }

    // Reuse an ongoing request for this season.
    if (_seasonDetailsRequests.containsKey(cacheKey)) {
      return _seasonDetailsRequests[cacheKey]!;
    }

    final request = tmdbRepository.getSeasonDetails(showId, seasonNumber);
    _seasonDetailsRequests[cacheKey] = request;

    try {
      final details = await request;

      _seasonsCache[cacheKey] = details;
      _seasonDetailsCacheTime[cacheKey] = DateTime.now();

      return details;
    } finally {
      _seasonDetailsRequests.remove(cacheKey);
    }
  }

  // --------------------------------------------------
  // LOAD LIBRARY SHOWS
  // --------------------------------------------------


  void loadMyShows() {
    isLoading.value = true;
    errorMessage.value = '';

    _showsSubscription =
        watchHistoryRepository.watchAddedShows().listen(
              (shows) async {
            try {
              final convertedShows = shows.map((data) {
                return UserShow.fromMap({
                  'tmdbId': (data['showId'] as num).toInt(),
                  'name': data['showTitle'] ?? 'Unknown Show',
                  'posterPath': data['posterPath'] ?? '',
                  'status': data['status'] ?? 'plan_to_watch',
                  'addedAt': data['addedAt'],
                });
              }).toList();

              // Update the main library list.
              myShows.assignAll(convertedShows);

              // Get IDs of shows that still exist in the library.
              final activeShowIds = convertedShows
                  .map((show) => show.tmdbId)
                  .toSet();

              // Remove cards belonging to shows removed from Firestore.
              currentlyWatching.removeWhere(
                    (episode) => !activeShowIds.contains(episode.showId),
              );

              planToWatch.removeWhere(
                    (episode) => !activeShowIds.contains(episode.showId),
              );

              upcomingEpisodes.removeWhere(
                    (episode) => !activeShowIds.contains(episode.showId),
              );

              _hasLoadedShows = true;

              debugPrint(
                'WATCHLIST: Loaded ${myShows.length} library shows',
              );

              await _refreshWhenReady();
            } catch (e) {
              errorMessage.value = e.toString();
              isLoading.value = false;
            }
          },
          onError: (error) {
            errorMessage.value = error.toString();
            isLoading.value = false;
          },
        );
  }

  // --------------------------------------------------
  // LOAD WATCHED EPISODES
  // --------------------------------------------------

  void loadWatchedEpisodes() {
    _watchedEpisodesSubscription =
        watchHistoryRepository.watchWatchedEpisodes().listen(
              (episodes) async {
            try {
              // Preserve the previous snapshot to identify changes.
              final previousKeys =
              Set<String>.from(_watchedEpisodeKeys);

              final newKeys = <String>{};
              final newShowsWithWatchedEpisodes = <int>{};

              for (final episode in episodes) {
                final showId = episode['showId'];
                final seasonNumber = episode['seasonNumber'];
                final episodeNumber = episode['episodeNumber'];

                if (showId is num &&
                    seasonNumber is num &&
                    episodeNumber is num) {
                  final id = showId.toInt();

                  newKeys.add(
                    _episodeKey(
                      id,
                      seasonNumber.toInt(),
                      episodeNumber.toInt(),
                    ),
                  );

                  newShowsWithWatchedEpisodes.add(id);
                }
              }

              // Find which episode records were added or removed.
              final changedKeys =
              previousKeys.difference(newKeys);

              changedKeys.addAll(
                newKeys.difference(previousKeys),
              );

              final affectedShowIds = <int>{};

              for (final key in changedKeys) {
                final showId =
                int.tryParse(key.split('_S').first);

                if (showId != null) {
                  affectedShowIds.add(showId);
                }
              }

              // Update lookup sets.
              _watchedEpisodeKeys
                ..clear()
                ..addAll(newKeys);

              _showsWithWatchedEpisodes
                ..clear()
                ..addAll(newShowsWithWatchedEpisodes);

              final isFirstEmission =
              !_hasLoadedWatchedEpisodes;

              _hasLoadedWatchedEpisodes = true;

              if (isFirstEmission) {
                debugPrint(
                  'WATCHLIST: Loaded '
                      '${_watchedEpisodeKeys.length} watched episodes',
                );

                // Initial load: classify all shows once.
                await _refreshWhenReady();
                return;
              }

              // Later emissions: update only affected shows.
              if (affectedShowIds.isNotEmpty) {
                debugPrint(
                  'WATCHLIST: Updating '
                      '${affectedShowIds.length} affected shows',
                );

                await _refreshShowsByIds(affectedShowIds);
              }
            } catch (e) {
              errorMessage.value = e.toString();
            }
          },
          onError: (error) {
            errorMessage.value = error.toString();
            isLoading.value = false;
          },
        );
  }

  // --------------------------------------------------
  // WAIT FOR BOTH FIRESTORE STREAMS
  // --------------------------------------------------

  Future<void> _refreshWhenReady() async {
    if (!_hasLoadedShows || !_hasLoadedWatchedEpisodes) {
      return;
    }

    await refreshWatchlist();
  }

  // --------------------------------------------------
  // CHECK WATCHED EPISODES
  // --------------------------------------------------

  bool isEpisodeWatched({
    required int showId,
    required int seasonNumber,
    required int episodeNumber,
  }) {
    return _watchedEpisodeKeys.contains(
      _episodeKey(
        showId,
        seasonNumber,
        episodeNumber,
      ),
    );
  }

  // --------------------------------------------------
  // FIND NEXT AVAILABLE EPISODE
  // --------------------------------------------------

  Future<WatchlistEpisode?> findNextAvailableEpisode(
      UserShow show,
      ) async {
    final details =
    await getCachedShowDetails(show.tmdbId);

    final seasons =
    (details['seasons'] as List<dynamic>? ?? [])
        .where(
          (season) =>
      (season['season_number'] as num).toInt() > 0,
    )
        .toList()
      ..sort(
            (a, b) =>
            (a['season_number'] as num)
                .compareTo(b['season_number'] as num),
      );

    for (final season in seasons) {
      final seasonNumber =
      (season['season_number'] as num).toInt();

      final seasonDetails = await getCachedSeasonDetails(
        show.tmdbId,
        seasonNumber,
      );

      final episodes =
          seasonDetails['episodes'] as List<dynamic>? ?? [];

      for (final episode in episodes) {
        final episodeNumber =
        (episode['episode_number'] as num).toInt();

        final watchlistEpisode =
        WatchlistEpisode.fromJson(
          showId: show.tmdbId,
          showTitle: show.name,
          seasonNumber: seasonNumber,
          json: Map<String, dynamic>.from(episode),
          posterPath: show.posterPath,
        );

        if (!watchlistEpisode.hasAired) {
          continue;
        }

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

  // --------------------------------------------------
  // FIND NEXT UPCOMING EPISODE
  // --------------------------------------------------

  Future<WatchlistEpisode?> findNextUpcomingEpisode(
      UserShow show,
      ) async {
    final details =
    await getCachedShowDetails(show.tmdbId);

    final seasons =
    (details['seasons'] as List<dynamic>? ?? [])
        .where(
          (season) =>
      (season['season_number'] as num).toInt() > 0,
    )
        .toList()
      ..sort(
            (a, b) =>
            (a['season_number'] as num)
                .compareTo(b['season_number'] as num),
      );

    WatchlistEpisode? nextEpisode;

    for (final season in seasons) {
      final seasonNumber =
      (season['season_number'] as num).toInt();

      final seasonDetails = await getCachedSeasonDetails(
        show.tmdbId,
        seasonNumber,
      );

      final episodes =
          seasonDetails['episodes'] as List<dynamic>? ?? [];

      for (final episode in episodes) {
        final watchlistEpisode =
        WatchlistEpisode.fromJson(
          showId: show.tmdbId,
          showTitle: show.name,
          seasonNumber: seasonNumber,
          json: Map<String, dynamic>.from(episode),
          posterPath: show.posterPath,
        );

        final airDate = watchlistEpisode.airDate;

        if (airDate == null ||
            !airDate.isAfter(DateTime.now())) {
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

  // --------------------------------------------------
  // MARK EPISODES WATCHED / UNWATCHED
  // --------------------------------------------------

  Future<void> markEpisodeWatched(
      WatchlistEpisode episode,
      ) async {
    await watchHistoryRepository.markEpisodeWatched(
      showId: episode.showId,
      showTitle: episode.showTitle,
      seasonNumber: episode.seasonNumber,
      episodeNumber: episode.episodeNumber,
      episodeTitle: episode.episodeTitle,
    );
  }

  Future<void> markEpisodeUnwatched(
      WatchlistEpisode episode,
      ) async {
    await watchHistoryRepository.markEpisodeUnwatched(
      showId: episode.showId,
      seasonNumber: episode.seasonNumber,
      episodeNumber: episode.episodeNumber,
    );
  }

  // --------------------------------------------------
  // CLASSIFY SHOW
  // --------------------------------------------------



  Future<_ShowClassification> _getShowClassification(
      UserShow show,
      ) async {
    final details = await getCachedShowDetails(show.tmdbId);

    final seasons = (details['seasons'] as List<dynamic>? ?? [])
        .where(
          (season) =>
      (season['season_number'] as num).toInt() > 0,
    )
        .toList()
      ..sort(
            (a, b) => (a['season_number'] as num)
            .compareTo(b['season_number'] as num),
      );

    final hasWatchedEpisodes =
    _showsWithWatchedEpisodes.contains(show.tmdbId);

    WatchlistEpisode? nextUpcoming;

    // Fetch two seasons concurrently per show.
    const seasonBatchSize = 2;

    for (var i = 0; i < seasons.length; i += seasonBatchSize) {
      final batch = seasons.skip(i).take(seasonBatchSize).toList();

      // Fetch this batch concurrently.
      final seasonDetailsList = await Future.wait(
        batch.map((season) {
          final seasonNumber =
          (season['season_number'] as num).toInt();

          return getCachedSeasonDetails(
            show.tmdbId,
            seasonNumber,
          );
        }),
      );

      // Process the responses in chronological season order.
      for (var j = 0; j < batch.length; j++) {
        final seasonNumber =
        (batch[j]['season_number'] as num).toInt();

        final episodes =
            seasonDetailsList[j]['episodes'] as List<dynamic>? ?? [];

        for (final episode in episodes) {
          final episodeNumber =
          (episode['episode_number'] as num).toInt();

          final watchlistEpisode = WatchlistEpisode.fromJson(
            showId: show.tmdbId,
            showTitle: show.name,
            seasonNumber: seasonNumber,
            json: Map<String, dynamic>.from(episode),
            posterPath: show.posterPath,
          );

          // Find the first aired episode that hasn't been watched.
          if (watchlistEpisode.hasAired) {
            if (!isEpisodeWatched(
              showId: show.tmdbId,
              seasonNumber: seasonNumber,
              episodeNumber: episodeNumber,
            )) {
              if (hasWatchedEpisodes) {
                return _ShowClassification(
                  currentlyWatching: watchlistEpisode,
                );
              }

              return _ShowClassification(
                planToWatch: watchlistEpisode,
              );
            }
          } else {
            // Remember the earliest upcoming episode.
            final airDate = watchlistEpisode.airDate;

            if (airDate != null &&
                airDate.isAfter(DateTime.now())) {
              if (nextUpcoming == null ||
                  airDate.isBefore(nextUpcoming.airDate!)) {
                nextUpcoming = watchlistEpisode;
              }
            }
          }
        }
      }
    }

    return _ShowClassification(upcoming: nextUpcoming);
  }


  Future<void> classifyShow(UserShow show) async {
    currentlyWatching.removeWhere(
          (episode) => episode.showId == show.tmdbId,
    );

    planToWatch.removeWhere(
          (episode) => episode.showId == show.tmdbId,
    );

    upcomingEpisodes.removeWhere(
          (episode) => episode.showId == show.tmdbId,
    );

    final result = await _getShowClassification(show);

    if (result.currentlyWatching != null) {
      currentlyWatching.add(result.currentlyWatching!);
    }

    if (result.planToWatch != null) {
      planToWatch.add(result.planToWatch!);
    }

    if (result.upcoming != null) {
      upcomingEpisodes.add(result.upcoming!);
    }
  }


  // --------------------------------------------------
  // REFRESH ONLY AFFECTED SHOWS
  // --------------------------------------------------

  Future<void> _refreshShowsByIds(
      Set<int> showIds,
      ) async {
    _pendingShowRefreshIds.addAll(showIds);

    if (_isRefreshing || _isRefreshingAffectedShows) {
      return;
    }

    _isRefreshingAffectedShows = true;

    try {
      while (_pendingShowRefreshIds.isNotEmpty) {
        final idsToRefresh =
        Set<int>.from(_pendingShowRefreshIds);

        _pendingShowRefreshIds.clear();

        final affectedShows = myShows
            .where(
              (show) => idsToRefresh.contains(show.tmdbId),
        )
            .toList();

        await Future.wait(
          affectedShows.map((show) async {
            try {
              await classifyShow(show);
            } catch (e) {
              debugPrint(
                'WATCHLIST: Failed to update '
                    '${show.name}: $e',
              );
            }
          }),
        );
      }
    } finally {
      _isRefreshingAffectedShows = false;

      // Process any updates queued during this refresh.
      if (_pendingShowRefreshIds.isNotEmpty &&
          !_isRefreshing) {
        await _refreshShowsByIds({});
      }
    }
  }

  // --------------------------------------------------
  // REFRESH ENTIRE WATCHLIST
  // --------------------------------------------------



  Future<void> refreshWatchlist() async {
    if (_isRefreshing || _isRefreshingAffectedShows) {
      _refreshRequested = true;
      return;
    }

    _isRefreshing = true;

    try {
      do {
        _refreshRequested = false;

        final newCurrentlyWatching = <WatchlistEpisode>[];
        final newPlanToWatch = <WatchlistEpisode>[];
        final newUpcomingEpisodes = <WatchlistEpisode>[];

        const batchSize = 5;

        for (var i = 0; i < myShows.length; i += batchSize) {
          final batch = myShows.skip(i).take(batchSize).toList();

          final results = await Future.wait(
            batch.map((show) async {
              try {
                return await _getShowClassification(show);
              } catch (e) {
                debugPrint(
                  'WATCHLIST: Failed to classify ${show.name}: $e',
                );

                return const _ShowClassification();
              }
            }),
          );

          for (final result in results) {
            if (result.currentlyWatching != null) {
              newCurrentlyWatching.add(result.currentlyWatching!);
            }

            if (result.planToWatch != null) {
              newPlanToWatch.add(result.planToWatch!);
            }

            if (result.upcoming != null) {
              newUpcomingEpisodes.add(result.upcoming!);
            }
          }

          // Publish the accumulated results after each batch.
          currentlyWatching.assignAll(newCurrentlyWatching);
          planToWatch.assignAll(newPlanToWatch);
          upcomingEpisodes.assignAll(newUpcomingEpisodes);

          // Stop showing the initial loading spinner after the first batch.
          if (isLoading.value) {
            isLoading.value = false;
          }

          debugPrint(
            'WATCHLIST: Processed '
                '${i + batch.length}/${myShows.length} shows',
          );
        }

        // Handle an empty watchlist.
        if (myShows.isEmpty) {
          currentlyWatching.clear();
          planToWatch.clear();
          upcomingEpisodes.clear();
          isLoading.value = false;
        }
      } while (_refreshRequested);
    } finally {
      _isRefreshing = false;
      isLoading.value = false;

      if (_pendingShowRefreshIds.isNotEmpty) {
        await _refreshShowsByIds({});
      }
    }
  }



  // --------------------------------------------------
  // OPEN SHOW DETAILS
  // --------------------------------------------------

  Future<void> openShowDetails(int showId) async {
    try {
      final showJson =
      await getCachedShowDetails(showId);

      final show = TvShow.fromJson(showJson);

      Get.toNamed(
        AppRoutes.showDetails,
        arguments: show,
      );
    } catch (e) {
      errorMessage.value =
      'Unable to open show details: $e';
    }
  }

  // --------------------------------------------------
  // OPEN EPISODE DETAILS
  // --------------------------------------------------

  Future<void> openEpisodeDetails(
      WatchlistEpisode selectedEpisode,
      ) async {
    try {
      final showJson = await getCachedShowDetails(
        selectedEpisode.showId,
      );

      final show = TvShow.fromJson(showJson);

      final seasonJson = await getCachedSeasonDetails(
        selectedEpisode.showId,
        selectedEpisode.seasonNumber,
      );

      final episodes =
      (seasonJson['episodes'] as List? ?? [])
          .map((episode) {
        final episodeMap =
        Map<String, dynamic>.from(episode);

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
      errorMessage.value =
      'Unable to open episode details: $e';
    }
  }



  Future<void> refreshPage() async {
    if (_isRefreshing || _isRefreshingAffectedShows) return;

    errorMessage.value = '';

    // Clear cached TMDB responses to force fresh data.
    _showDetailsCache.clear();
    _seasonsCache.clear();

    _showDetailsCacheTime.clear();
    _seasonDetailsCacheTime.clear();

    await refreshWatchlist();
  }


  // --------------------------------------------------
  // CLEANUP
  // --------------------------------------------------

  @override
  void onClose() {
    _showsSubscription?.cancel();
    _watchedEpisodesSubscription?.cancel();

    _showDetailsCache.clear();
    _seasonsCache.clear();

    _showDetailsCacheTime.clear();
    _seasonDetailsCacheTime.clear();

    _showDetailsRequests.clear();
    _seasonDetailsRequests.clear();

    _watchedEpisodeKeys.clear();
    _showsWithWatchedEpisodes.clear();
    _pendingShowRefreshIds.clear();

    super.onClose();
  }
}
