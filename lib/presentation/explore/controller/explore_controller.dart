import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../data/models/tmdb_models/popular.dart';
import '../../../data/repositories/tmdb_repostiory.dart';


class ExploreController extends GetxController {
  final TmdbRepository tmdbRepository = Get.find<TmdbRepository>();

  final popularTvShows = Rxn<Popular>();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPopularTvShows();
  }

  Future<void> fetchPopularTvShows() async {
    try {
      isLoading.value = true;

      popularTvShows.value = await tmdbRepository.getPopularTvShows();
    } catch (e) {
      print('Error details: $e');
    } finally {
      isLoading.value = false;
    }
  }
}