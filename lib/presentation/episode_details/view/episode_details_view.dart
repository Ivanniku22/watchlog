import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/episode_details_controller.dart';

class EpisodeDetailsView extends GetView<EpisodeDetailsController> {
  const EpisodeDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Episode Details'),
      ),
      body: Center(
        child: Text(controller.episode['name'] ?? 'Untitled Episode'),
      ),
    );
  }
}