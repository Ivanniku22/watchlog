import 'package:get/get.dart';
import '../../../data/repositories/watch_history_repository.dart';
import '../controller/all_shows_controller.dart';

class AllShowsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AllShowsController>(
          () => AllShowsController(
        watchHistoryRepository: Get.find<WatchHistoryRepository>(),
      ),
    );
  }
}