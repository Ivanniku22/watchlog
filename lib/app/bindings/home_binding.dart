import 'package:get/get.dart';

import '../../data/repositories/show_repository.dart';
import '../../presentation/home/controller/home_view_model.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShowRepository>(() => ShowRepository());
    Get.lazyPut<HomeViewModel>(
          () => HomeViewModel(
        showRepository: Get.find<ShowRepository>(),
      ),
    );
  }
}