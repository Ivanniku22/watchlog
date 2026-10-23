import 'package:get/get.dart';
import 'package:watchlog/data/models/tmdb_models/popular.dart';
import 'package:watchlog/presentation/show_details/controller/show_details_controller.dart';

class ShowDetailsBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShowDetailsController>(
          () => ShowDetailsController(
        Get.arguments as TvShow,
      ),
    );
  }
}