
import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter/widgets.dart';
import '../../../../data/repositories/tmdb_repostiory.dart';
import '../../../../data/repositories/watch_history_repository.dart';

class MoviesController extends GetxController with WidgetsBindingObserver{
  final WatchHistoryRepository watchHistoryRepository =
  Get.find<WatchHistoryRepository>();

  final TmdbRepository tmdbRepository = Get.find<TmdbRepository>();

  final RxList<Map<String, dynamic>> watchListMovies =
      <Map<String, dynamic>>[].obs;

  final RxList<Map<String, dynamic>> upcomingMovies =
      <Map<String, dynamic>>[].obs;

  final isLoading = true.obs;
  final errorMessage = ''.obs;

  StreamSubscription<List<Map<String, dynamic>>>? _addedMoviesSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _watchedMoviesSubscription;

  final Set<int> _watchedMovieIds = {};
  final Map<int, String> _releaseDateCache = {};

  List<Map<String, dynamic>> _addedMovies = [];

  bool _isProcessing = false;
  bool _refreshRequested = false;
  Timer? _releaseDateCheckTimer;

  @override
  void onInit() {
    super.onInit();

    WidgetsBinding.instance.addObserver(this);

    _listenToMovies();

    // Recheck release dates periodically while the app is open.
    _releaseDateCheckTimer = Timer.periodic(
      const Duration(minutes: 5),
          (_) => _processMovies(),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _processMovies();
    }
  }

  void _listenToMovies() {
    _addedMoviesSubscription =
        watchHistoryRepository.watchAddedMovies().listen(
              (movies) {
            _addedMovies = movies;
            _processMovies();
          },
          onError: (error) {
            errorMessage.value = 'Failed to load your movies.';
            isLoading.value = false;
          },
        );

    _watchedMoviesSubscription =
        watchHistoryRepository.watchWatchedMovies().listen(
              (movies) {
            _watchedMovieIds
              ..clear()
              ..addAll(
                movies.map(
                      (movie) => (movie['movieId'] as num).toInt(),
                ),
              );

            _processMovies();
          },
          onError: (error) {
            errorMessage.value = 'Failed to load watched movies.';
            isLoading.value = false;
          },
        );
  }

  Future<void> _processMovies() async {
    if (_isProcessing) {
      _refreshRequested = true;
      return;
    }

    _isProcessing = true;

    try {
      do {
        _refreshRequested = false;

        final watchList = <Map<String, dynamic>>[];
        final upcoming = <Map<String, dynamic>>[];

        for (final movie in _addedMovies) {
          final movieId = (movie['movieId'] as num).toInt();

          if (_watchedMovieIds.contains(movieId)) {
            continue;
          }

          String releaseDate =
              movie['releaseDate']?.toString() ?? '';

          if (releaseDate.isEmpty) {
            releaseDate = await _getReleaseDate(movieId);

            if (releaseDate.isNotEmpty) {
              await watchHistoryRepository.updateMovieReleaseDate(
                movieId: movieId,
                releaseDate: releaseDate,
              );
            }
          }

          final parsedDate = DateTime.tryParse(releaseDate);

          final movieWithDate = {
            ...movie,
            'releaseDate': releaseDate,
          };

          if (parsedDate == null ||
              !parsedDate.isAfter(DateTime.now())) {
            watchList.add(movieWithDate);
          } else {
            upcoming.add(movieWithDate);
          }
        }

        watchListMovies.assignAll(watchList);
        upcomingMovies.assignAll(upcoming);

        isLoading.value = false;
        errorMessage.value = '';
      } while (_refreshRequested);
    } catch (e) {
      errorMessage.value = 'Something went wrong while loading movies.';
      isLoading.value = false;
    } finally {
      _isProcessing = false;
    }
  }

  Future<String> _getReleaseDate(int movieId) async {
    if (_releaseDateCache.containsKey(movieId)) {
      return _releaseDateCache[movieId]!;
    }

    try {
      final details = await tmdbRepository.getMovieDetails(movieId);

      final releaseDate = details['release_date']?.toString() ?? '';

      _releaseDateCache[movieId] = releaseDate;

      return releaseDate;
    } catch (e) {
      return '';
    }
  }

  @override
  void onClose() {
    _addedMoviesSubscription?.cancel();
    _watchedMoviesSubscription?.cancel();

    _releaseDateCheckTimer?.cancel();

    WidgetsBinding.instance.removeObserver(this);

    super.onClose();
  }
}
