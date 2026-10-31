import 'package:get/get.dart';
import '../controller/episode_details_controller.dart';

class EpisodeDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EpisodeDetailsController>(
          () => EpisodeDetailsController(),
    );
  }
}