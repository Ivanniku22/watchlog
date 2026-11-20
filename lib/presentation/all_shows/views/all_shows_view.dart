
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/all_shows_controller.dart';

class AllShowsView extends GetView<AllShowsController> {
  const AllShowsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Shows'),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels >=
              notification.metrics.maxScrollExtent - 300) {
            controller.loadMoreShows();
          }
          return false;
        },
        child: Obx(() {
          final shows = controller.shows;

          if (shows.isEmpty && controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (shows.isEmpty) {
            return const Center(
              child: Text('No shows added yet'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: shows.length +
                (controller.hasMore.value ? 1 : 0),
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 6,
              mainAxisSpacing: 8,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              if (index >= shows.length) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final show = shows[index];
              final posterPath = show['posterPath'];

              return GestureDetector(
                onTap: () => controller.openShowDetails(show),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: posterPath != null
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
