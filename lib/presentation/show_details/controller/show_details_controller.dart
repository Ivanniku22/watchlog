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
      print('Failed to fetch show details: $e');
    } finally {
      isLoadingDetails.value = false;
    }
  }
}