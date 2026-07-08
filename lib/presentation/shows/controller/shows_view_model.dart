import 'package:get/get.dart';

import '../../../data/repositories/show_repository.dart';

class ShowsViewModel extends GetxController {
  ShowsViewModel({required this.showRepository});

  final ShowRepository showRepository;

  final selectedIndex = 0.obs;

  static const navTitles = ['Shows', 'Movies', 'Explore', 'Profile'];

  void changeTab(int index) {
    selectedIndex.value = index;
  }

  String get selectedTitle => navTitles[selectedIndex.value];
}
