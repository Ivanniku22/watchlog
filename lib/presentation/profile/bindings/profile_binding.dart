import 'package:get/get.dart';

import '../../../data/repositories/auth_repository.dart';
import '../controller/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(
      () => ProfileController(authRepository: Get.find<AuthRepository>()),
    );
  }
}
