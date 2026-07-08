import 'package:get/get.dart';

import '../../../data/models/show_model.dart';
import '../../../data/repositories/show_repository.dart';

class HomeViewModel extends GetxController {
  HomeViewModel({
    required this.showRepository,
  });

  final ShowRepository showRepository;


  @override
  void onInit() {
    super.onInit();
  }

}