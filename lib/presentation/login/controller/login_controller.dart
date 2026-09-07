import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/repositories/auth_repository.dart';

class LoginController extends GetxController {
  LoginController({AuthRepository? authRepository})
      : _authRepository = authRepository ?? Get.find<AuthRepository>();

  final AuthRepository _authRepository;

  final isLoading = false.obs;

  Future<void> signInWithGoogle() async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      await _authRepository.signInWithGoogle();
      Get.offAllNamed(AppRoutes.shows);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return;
      Get.snackbar(
        'Sign-in failed',
        e.description ?? e.code.name,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Sign-in failed',
        e.message ?? e.code,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Sign-in failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
