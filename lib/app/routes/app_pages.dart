import 'package:get/get.dart';

import '../../presentation/explore/bindings/explore_binding.dart';
import '../../presentation/explore/view/explore.dart';
import '../../presentation/movies/bindings/movies_binding.dart';
import '../../presentation/movies/view/movies.dart';
import '../../presentation/profile/bindings/profile_binding.dart';
import '../../presentation/profile/view/profile.dart';
import '../../presentation/shows/bindings/shows_binding.dart';
import '../../presentation/shows/view/shows_view.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.shows;

  static final routes = [
    GetPage(
      name: AppRoutes.shows,
      page: () => const ShowsView(),
      binding: ShowsBinding(),
    ),

    GetPage(
      name: AppRoutes.movies,
      page: () => const Movies(),
      binding: MoviesBinding(),
    ),
    GetPage(
      name: AppRoutes.explore,
      page: () => const Explore(),
      binding: ExploreBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const Profile(),
      binding: ProfileBinding(),
    ),
  ];
}
