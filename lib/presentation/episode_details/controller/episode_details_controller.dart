import 'package:get/get.dart';
import 'package:watchlog/data/models/tmdb_models/popular.dart';

import '../../show_details/controller/show_details_controller.dart';

class EpisodeDetailsController extends GetxController {
  final Map<String, dynamic> arguments =
  Get.arguments as Map<String, dynamic>;

  Map<String, dynamic> get episode => episodes[currentIndex.value];
  late final TvShow show = arguments['show'] as TvShow;

  final List<Map<String, dynamic>> episodes =
  (Get.arguments['episodes'] as List)
      .map((episode) => Map<String, dynamic>.from(episode as Map))
      .toList();

  final RxInt currentIndex = 0.obs;

  int get currentEpisodeNumber =>
      episodes[currentIndex.value]['episode_number'] as int;

  int get totalEpisodes => episodes.length;

  void changeEpisode(int index) {
    if (index < 0 || index >= episodes.length) return;

    currentIndex.value = index;
  }

  void nextEpisode() {
    if (currentIndex.value < episodes.length - 1) {
      currentIndex.value++;
    }
  }

  void previousEpisode() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
    }
  }
}