
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watchlog/presentation/show_details/controller/show_details_controller.dart';

class ShowDetailsView extends GetView<ShowDetailsController> {
  const ShowDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final show = controller.show;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          show.name,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      body: Center(
        child: Text(
          show.overview,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
