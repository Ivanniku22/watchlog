import 'package:get/get.dart';

import '../../data/repositories/show_repository.dart';
import '../../presentation/shows/controller/shows_view_model.dart';
import '../../presentation/shows/upcoming/controller/upcoming_controller.dart';
import '../../presentation/shows/watch_list/controller/watchlist_controller.dart';

class ShowsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShowRepository>(() => ShowRepository());
    Get.lazyPut<ShowsViewModel>(
      () => ShowsViewModel(showRepository: Get.find<ShowRepository>()),
    );
    Get.lazyPut<WatchlistController>(() => WatchlistController());
    Get.lazyPut<UpcomingController>(() => UpcomingController());
  }
}
