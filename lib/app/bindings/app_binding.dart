import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

import '../../data/repositories/show_repository.dart';
import '../../data/repositories/tmdb_repostiory.dart';
import '../../presentation/episodes/controller/episode_progress_controller.dart';
import '../../presentation/explore/controller/explore_controller.dart';
import '../../services/tmdb_client.dart';
import '../../services/tmdb_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/watch_history_repository.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FirebaseFirestore>(
          () => FirebaseFirestore.instance,
    );

    Get.lazyPut<Dio>(createTmdbDio);

    Get.lazyPut<TmdbService>(
          () => TmdbService(Get.find<Dio>()),
    );

    Get.lazyPut<ShowRepository>(
          () => ShowRepository(
        firestore: Get.find<FirebaseFirestore>(),
        auth: FirebaseAuth.instance,
      ),
    );

    Get.lazyPut<TmdbRepository>(
          () => TmdbRepository(Get.find<TmdbService>()),
    );

    Get.lazyPut<WatchHistoryRepository>(
          () => WatchHistoryRepository(
        firestore: Get.find<FirebaseFirestore>(),
        auth: FirebaseAuth.instance,
      ),
    );

    Get.put<ExploreController>(ExploreController());

    Get.put<EpisodeProgressController>(EpisodeProgressController());

  }
}