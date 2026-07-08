import 'package:get/get.dart';

import '../../presentation/home/view/home_view.dart';
import '../bindings/home_binding.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.home;

  static final routes = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
  ];
}