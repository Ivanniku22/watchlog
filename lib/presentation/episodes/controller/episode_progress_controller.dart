
import 'package:get/get.dart';
import '../../../data/repositories/watch_history_repository.dart';

class EpisodeProgressController extends GetxController {
  EpisodeProgressController()
      : _repository = Get.find<WatchHistoryRepository>();

  final WatchHistoryRepository _repository;

  final RxMap<String, bool> watchedEpisodes = <String, bool>{}.obs;

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

      watchedEpisodes[key] = watched;
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

    // Update the UI immediately.
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
      // Restore the previous state if Firestore fails.
      watchedEpisodes[key] = previousValue;
      Get.snackbar('Error', 'Could not update episode progress.');
    }
  }
}
