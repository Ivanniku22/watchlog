import 'package:get/get.dart';
import 'package:dio/dio.dart';

import '../../data/repositories/tmdb_repostiory.dart';
import '../../presentation/explore/controller/explore_controller.dart';
import '../../services/tmdb_service.dart';


class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<Dio>(createTmdbDio);

    Get.lazyPut<TmdbService>(
          () => TmdbService(Get.find<Dio>()),
    );

    Get.lazyPut<TmdbRepository>(
          () => TmdbRepository(Get.find<TmdbService>()),
    );

    Get.put<ExploreController>(ExploreController());
  }
}