import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watchlog/app/bindings/app_binding.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Get.put(AuthRepository());

  final loggedIn = FirebaseAuth.instance.currentUser != null;
  runApp(WatchLogApp(
    initialRoute: loggedIn ? AppRoutes.shows : AppRoutes.login,
  ));
}

class WatchLogApp extends StatelessWidget {
  const WatchLogApp({super.key,required this.initialRoute,});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'WatchLog',
      debugShowCheckedModeBanner: false,
      initialBinding: AppBinding(),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: initialRoute,
      getPages: AppPages.routes,
    );
  }
}
