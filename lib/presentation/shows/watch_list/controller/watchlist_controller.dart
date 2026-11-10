
import 'dart:async';

import 'package:get/get.dart';

import '../../../../data/models/user_show.dart';
import '../../../../data/repositories/show_repository.dart';

class WatchlistController extends GetxController {
  WatchlistController({required this.showRepository});

  final ShowRepository showRepository;

  final RxList<UserShow> myShows = <UserShow>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  StreamSubscription<List<UserShow>>? _showsSubscription;

  @override
  void onInit() {
    super.onInit();
    loadMyShows();
  }

  void loadMyShows() {
    isLoading.value = true;
    errorMessage.value = '';

    _showsSubscription = showRepository.getMyShows().listen(
          (shows) {
        myShows.assignAll(shows);
        isLoading.value = false;
      },
      onError: (error) {
        errorMessage.value = error.toString();
        isLoading.value = false;
      },
    );
  }

  @override
  void onClose() {
    _showsSubscription?.cancel();
    super.onClose();
  }
}
