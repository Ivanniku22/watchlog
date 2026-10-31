import 'package:get/get.dart';

class EpisodeProgressController extends GetxController {
  final RxMap<int, bool> watchedEpisodes = <int, bool>{}.obs;

  bool isWatched(int episodeId) {
    return watchedEpisodes[episodeId] ?? false;
  }

  void toggleWatched(int episodeId) {
    watchedEpisodes[episodeId] = !isWatched(episodeId);
  }
}