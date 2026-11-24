
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/tmdb_models/search_result.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../movies/controller/movies_controller.dart';

class Upcoming extends GetView<MoviesController> {
  const Upcoming({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return Center(
          child: Text(controller.errorMessage.value),
        );
      }

      final movies = controller.upcomingMovies;

      if (movies.isEmpty) {
        return const Center(
          child: Text('No upcoming movies in your watch list.'),
        );
      }

      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: movies.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 3,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.6,
                ),
                itemBuilder: (context, index) {
                  final movie = movies[index];

                  final posterPath =
                  movie['posterPath'] as String?;

                  return GestureDetector(
                    onTap: () {
                      final searchResult = SearchResult(
                        id: (movie['movieId'] as num).toInt(),
                        mediaType: 'movie',
                        title: movie['movieTitle'] ?? '',
                        posterPath: posterPath,
                        backdropPath:
                        movie['backdropPath'] as String?,
                        overview: '',
                        voteAverage: 0.0,
                        releaseDate:
                        movie['releaseDate']?.toString() ?? '',
                      );

                      Get.toNamed(
                        AppRoutes.movieDetails,
                        arguments: searchResult,
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: posterPath != null &&
                          posterPath.isNotEmpty
                          ? Image.network(
                        'https://image.tmdb.org/t/p/w342$posterPath',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const ColoredBox(
                            color: Colors.black12,
                            child: Icon(Icons.movie),
                          );
                        },
                      )
                          : const ColoredBox(
                        color: Colors.black12,
                        child: Icon(Icons.movie),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    });
  }
}
