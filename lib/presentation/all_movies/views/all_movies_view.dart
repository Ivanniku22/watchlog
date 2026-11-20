
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/all_movies_controller.dart';

class AllMoviesView extends GetView<AllMoviesController> {
  const AllMoviesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Movies'),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels >=
              notification.metrics.maxScrollExtent - 300) {
            controller.loadMoreMovies();
          }
          return false;
        },
        child: Obx(() {
          final movies = controller.movies;

          if (movies.isEmpty && controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (movies.isEmpty) {
            return const Center(
              child: Text('No movies added yet'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: movies.length +
                (controller.hasMore.value ? 1 : 0),
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 6,
              mainAxisSpacing: 8,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              if (index >= movies.length) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final movie = movies[index];
              final posterPath = movie['posterPath'];

              return GestureDetector(
                onTap: () => controller.openMovieDetails(movie),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: posterPath != null &&
                      posterPath.toString().isNotEmpty
                      ? Image.network(
                    'https://image.tmdb.org/t/p/w342$posterPath',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _posterFallback();
                    },
                  )
                      : _posterFallback(),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _posterFallback() {
    return Container(
      color: Colors.grey.shade800,
      child: const Center(
        child: Icon(
          Icons.movie_outlined,
          color: Colors.white,
          size: 35,
        ),
      ),
    );
  }
}
