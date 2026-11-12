import 'package:get/get.dart';
import 'package:watchlog/data/models/tmdb_models/popular.dart';
import '../../episodes/controller/episode_progress_controller.dart';

class EpisodeDetailsController extends GetxController {
  final Map<String, dynamic> arguments =
  Get.arguments as Map<String, dynamic>;

  late final TvShow show = arguments['show'] as TvShow;

  final List<Map<String, dynamic>> episodes =
  (Get.arguments['episodes'] as List)
      .map((episode) => Map<String, dynamic>.from(episode as Map))
      .toList();

  final RxInt currentIndex = 0.obs;

  late final EpisodeProgressController _progressController;

  Map<String, dynamic> get episode => episodes[currentIndex.value];

  int get currentEpisodeNumber =>
      episodes[currentIndex.value]['episode_number'] as int;

  int get totalEpisodes => episodes.length;

  @override
  void onInit() {
    super.onInit();

    _progressController = Get.find<EpisodeProgressController>();

    final selectedEpisode =
    arguments['episode'] as Map<String, dynamic>;

    final selectedEpisodeId = selectedEpisode['id'];

    final index = episodes.indexWhere(
          (episode) => episode['id'] == selectedEpisodeId,
    );

    if (index != -1) {
      currentIndex.value = index;
    }

    _loadCurrentEpisodeStatus();
  }

  void _loadCurrentEpisodeStatus() {
    final currentEpisode = episode;

    _progressController.loadEpisodeStatus(
      showId: show.id,
      seasonNumber: currentEpisode['season_number'] as int,
      episodeNumber: currentEpisode['episode_number'] as int,
    );
  }

  void changeEpisode(int index) {
    if (index < 0 || index >= episodes.length) return;

    currentIndex.value = index;
    _loadCurrentEpisodeStatus();
  }

  void nextEpisode() {
    if (currentIndex.value < episodes.length - 1) {
      currentIndex.value++;
      _loadCurrentEpisodeStatus();
    }
  }

  void previousEpisode() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
      _loadCurrentEpisodeStatus();
    }
  }
}
