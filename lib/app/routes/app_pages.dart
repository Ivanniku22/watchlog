import 'package:get/get.dart';

import '../../presentation/shows/view/shows_view.dart';
import '../bindings/shows_binding.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.shows;

  static final routes = [
    GetPage(
      name: AppRoutes.shows,
      page: () => const ShowsView(),
      binding: ShowsBinding(),
    ),
  ];
}
