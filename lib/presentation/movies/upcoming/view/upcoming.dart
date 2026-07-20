import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watchlog/data/upcoming_movie_data.dart';
import 'package:watchlog/presentation/movies/upcoming/controller/upcoming_controller.dart';

class Upcoming extends GetView <UpcomingController>{
  const Upcoming({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:const EdgeInsets.all(10),
      child: GridView.builder(
          itemCount: upcomingMovies.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 3,
            mainAxisSpacing: 8,
            childAspectRatio: 0.6,
          ),
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                upcomingMovies[index].poster,
                fit: BoxFit.cover,
              ),
            );
          }
      ),
    );
  }

}