import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watchlog/data/watchlist_movie_data.dart';
import 'package:watchlog/presentation/movies/watch_list/controller/watchlist_controller.dart';

class Watchlist extends GetView<WatchlistController>{
  const Watchlist({super.key});

  @override
  Widget build(BuildContext context) {

    return Padding(
        padding:const EdgeInsets.all(10),
        child: GridView.builder(
            itemCount: watchlistMovies.length,
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
                  watchlistMovies[index].poster,
                  fit: BoxFit.cover,
                ),
              );
            }
        ),
    );
  }

}