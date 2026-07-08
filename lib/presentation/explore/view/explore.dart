import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watchlog/presentation/explore/controller/explore_controller.dart';

class Explore extends GetView<ExploreController>{

  const Explore({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Explore',
        style: Theme.of(context).textTheme.bodyMedium
      ),
    );
  }

}