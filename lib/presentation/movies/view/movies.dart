import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watchlog/presentation/movies/controller/movies_controller.dart';

class Movies extends GetView<MoviesController>{
  const Movies ({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
          'Movies',
          style: Theme.of(context).textTheme.bodyMedium
      ),
    );
  }


}