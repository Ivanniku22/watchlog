import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/login_controller.dart';

class Login extends GetView<LoginController> {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.movie_outlined,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'WatchLog',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue',
                style: theme.textTheme.bodyMedium,
              ),
              const Spacer(flex: 3),
              Obx(() {
                final loading = controller.isLoading.value;
                return SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: loading ? null : controller.signInWithGoogle,
                    icon: loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.g_mobiledata, size: 28),
                    label: Text(loading ? 'Signing in…' : 'Continue with Google'),
                  ),
                );
              }),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
