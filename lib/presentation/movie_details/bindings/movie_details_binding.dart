import 'package:get/get.dart';

import '../../../data/models/tmdb_models/search_result.dart';
import '../controllers/movie_details_controller.dart';


class MovieDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MovieDetailsController>(
          () => MovieDetailsController(Get.arguments as SearchResult),
    );
  }
}