import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/models/app_user.dart';
import '../../../data/repositories/auth_repository.dart';

class ProfileController extends GetxController {
  ProfileController({AuthRepository? authRepository})
      : _authRepository = authRepository ?? Get.find<AuthRepository>();

  final AuthRepository _authRepository;

  final user = Rxn<AppUser>();
  final isSigningOut = false.obs;

  @override
  void onInit() {
    super.onInit();
    user.value = _authRepository.currentUser;
  }

  Future<void> signOut() async {
    if (isSigningOut.value) return;

    isSigningOut.value = true;
    try {
      await _authRepository.signOut();
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      Get.snackbar(
        'Sign out failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSigningOut.value = false;
    }
  }
}
