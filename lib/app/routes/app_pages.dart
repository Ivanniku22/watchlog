import 'package:get/get.dart';
import 'package:watchlog/presentation/show_details/bindings/show_details_bindings.dart';
import 'package:watchlog/presentation/show_details/view/show_details_view.dart';

import '../../presentation/explore/bindings/explore_binding.dart';
import '../../presentation/explore/view/explore.dart';
import '../../presentation/login/bindings/login_binding.dart';
import '../../presentation/login/view/login.dart';
import '../../presentation/movies/bindings/movies_binding.dart';
import '../../presentation/movies/view/movies.dart';
import '../../presentation/profile/bindings/profile_binding.dart';
import '../../presentation/profile/view/profile.dart';
import '../../presentation/shows/bindings/shows_binding.dart';
import '../../presentation/shows/view/shows_view.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.login;

  static final routes = [
    GetPage(
      name: AppRoutes.login,
      page: () => const Login(),
      binding: LoginBinding(),
    ),

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
    GetPage(
        name: AppRoutes.showDetails,
        page: () => const ShowDetailsView(),
        binding: ShowDetailsBindings(),
        transition: Transition.downToUp,
        transitionDuration: const Duration(milliseconds: 350),
    ),
  ];
}
