import 'package:get/get.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/show_repository.dart';
import '../../profile/controller/profile_controller.dart';
import '../controller/shows_view_controller.dart';
import '../watch_list/controller/watchlist_controller.dart';
import '../../../data/repositories/watch_history_repository.dart';
import '../../../data/repositories/tmdb_repostiory.dart';

class ShowsBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut<ShowRepository>(() => ShowRepository());
    Get.lazyPut<ShowsViewModel>(
      () => ShowsViewModel(showRepository: Get.find<ShowRepository>()),
    );
    Get.lazyPut<WatchlistController>(
          () => WatchlistController(
        watchHistoryRepository: Get.find<WatchHistoryRepository>(),
        tmdbRepository: Get.find<TmdbRepository>(),
      ),
    );
    Get.lazyPut<ProfileController>(
      () => ProfileController(authRepository: Get.find<AuthRepository>()),
    );
  }
}
