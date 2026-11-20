import 'package:get/get.dart';

import '../../../data/repositories/watch_history_repository.dart';
import '../controller/all_movies_controller.dart';

class AllMoviesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AllMoviesController>(
          () => AllMoviesController(
        watchHistoryRepository: Get.find<WatchHistoryRepository>(),
      ),
    );
  }
}