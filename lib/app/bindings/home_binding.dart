import 'package:get/get.dart';

import '../../data/repositories/show_repository.dart';
import '../../presentation/home/controller/home_view_model.dart';
import '../../presentation/upcoming/controller/upcoming_controller.dart';
import '../../presentation/watch_list/controller/watchlist_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShowRepository>(() => ShowRepository());
    Get.lazyPut<HomeViewModel>(
      () => HomeViewModel(showRepository: Get.find<ShowRepository>()),
    );
    Get.lazyPut<WatchlistController>(() => WatchlistController());
    Get.lazyPut<UpcomingController>(() => UpcomingController());
  }
}
