import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../data/models/tmdb_models/popular.dart';
import '../../../data/repositories/tmdb_repostiory.dart';

class ShowDetailsController extends GetxController{
  ShowDetailsController(this.show);

  final TvShow show;

  final TmdbRepository tmdbRepository = Get.find<TmdbRepository>();

  final Rxn<Map<String, dynamic>> showDetails =
  Rxn<Map<String, dynamic>>();

  final isLoadingDetails = true.obs;
  final loadedSeasonNumbers = <int>{}.obs;
  final loadingSeasonNumbers = <int>{}.obs;

  final RxList<Map<String, dynamic>> seasonDetails =
      <Map<String, dynamic>>[].obs;

  final isLoadingSeasons = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchShowDetails();
  }

  Future<void> fetchShowDetails() async {
    try {
      final details = await tmdbRepository.getTvShowDetails(show.id);
      showDetails.value = details;
    } catch (e) {
      debugPrint('Failed to fetch show details: $e');
    } finally {
      isLoadingDetails.value = false;
    }
  }


  Future<void> fetchSeasonDetails(int seasonNumber) async {
    if (loadedSeasonNumbers.contains(seasonNumber) ||
        loadingSeasonNumbers.contains(seasonNumber)) {
      return;
    }

    loadingSeasonNumbers.add(seasonNumber);

    try {
      final result = await tmdbRepository.getSeasonDetails(
        show.id,
        seasonNumber,
      );

      seasonDetails.removeWhere(
            (season) => season['season_number'] == seasonNumber,
      );

      seasonDetails.add(result);
      loadedSeasonNumbers.add(seasonNumber);
    } catch (e) {
      debugPrint('Failed to fetch season $seasonNumber: $e');
    } finally {
      loadingSeasonNumbers.remove(seasonNumber);
    }
  }

}