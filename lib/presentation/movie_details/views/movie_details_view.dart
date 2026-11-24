
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/movie_details_controller.dart';

class MovieDetailsView extends GetView<MovieDetailsController> {
  const MovieDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [

          SliverAppBar(
            expandedHeight: 250,
            pinned: false,
            automaticallyImplyLeading: false,
            floating: false,
            toolbarHeight: kToolbarHeight,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
                size: 30,
              ),
            ),
            actions: [
              Obx(
                    () => PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_horiz,
                    color: Colors.white,
                    size: 25,
                  ),
                  onSelected: (value) {
                    if (value == 'watchlist') {
                      controller.addToWatchlist();
                    } else if (value == 'remove') {
                      Get.dialog(
                        AlertDialog(
                          title: const Text('Remove movie?'),
                          content: Text(
                            'Remove "${controller.movie.title}" from your library?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.back();
                                controller.removeFromWatchlist();
                              },
                              child: const Text('Remove'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  itemBuilder: (context) {
                    if (controller.isMovieAdded.value) {
                      return const [
                        PopupMenuItem(
                          value: 'remove',
                          child: Text('Remove from watch list'),
                        ),
                      ];
                    }

                    return const [
                      PopupMenuItem(
                        value: 'watchlist',
                        child: Text('Add to watch list'),
                      ),
                    ];
                  },
                ),
              )
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Backdrop image
                  if (controller.movie.backdropPath != null &&
                      controller.movie.backdropPath!.isNotEmpty)
                    Image.network(
                      'https://image.tmdb.org/t/p/w780${controller.movie.backdropPath}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(color: Colors.grey.shade900);
                      },
                    )
                  else
                    Container(color: Colors.grey.shade900),

                  // Dark overlay
                  Container(
                    color: Colors.black.withValues(alpha: 0.4),
                  ),

                  // Movie title and metadata
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.movie.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Metadata
                          Obx(() {
                            if (controller.isLoadingDetails.value) {
                              return Row(
                                children: [
                                  _skeletonBar(65),
                                  const SizedBox(width: 10),
                                  _skeletonBar(75),
                                  const SizedBox(width: 10),
                                  _skeletonBar(55),
                                ],
                              );
                            }

                            final details = controller.movieDetails.value;

                            if (details == null) {
                              return const SizedBox.shrink();
                            }

                            final releaseDate =
                                details['release_date'] as String? ?? '';

                            final year = releaseDate.length >= 4
                                ? releaseDate.substring(0, 4)
                                : 'Unknown';

                            final runtime = details['runtime'];

                            final genres =
                                (details['genres'] as List<dynamic>?)
                                    ?.map((genre) => genre['name'] as String)
                                    .toList() ??
                                    [];

                            const metadataStyle = TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            );

                            return Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(year, style: metadataStyle),
                                if (runtime != null)
                                  Text(
                                    '• $runtime min',
                                    style: metadataStyle,
                                  ),
                                ...genres.map(
                                      (genre) => Text(
                                    '• $genre',
                                    style: metadataStyle,
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // About content
          SliverToBoxAdapter(
            child: MovieAboutTab(),
          ),
        ],
      ),
    );
  }

  Widget _skeletonBar(double width) {
    return Container(
      width: width,
      height: 12,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class MovieAboutTab extends GetView<MovieDetailsController> {
  const MovieAboutTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingDetails.value) {
        return const SizedBox(
          height: 250,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      final details = controller.movieDetails.value;

      if (details == null) {
        return const Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text('Unable to load movie information.'),
          ),
        );
      }

      final rating =
          (details['vote_average'] as num?)?.toDouble() ?? 0.0;

      final starRating = (rating / 2).clamp(0.0, 5.0);

      final overview = details['overview'] as String? ?? '';
      final status = details['status'] as String? ?? 'Unknown';
      final releaseDate =
          details['release_date'] as String? ?? 'Unknown';
      final runtime = details['runtime'];
      final language =
          details['original_language'] as String? ?? 'Unknown';

      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              overview.isEmpty
                  ? 'No overview available.'
                  : overview,
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 24),

            // Rating stars
            Row(
              children: [
                ...List.generate(5, (index) {
                  final starPosition = index + 1;

                  return Icon(
                    starRating >= starPosition
                        ? Icons.star
                        : starRating >= starPosition - 0.5
                        ? Icons.star_half
                        : Icons.star_border,
                    color: starRating >= starPosition - 0.5
                        ? Colors.amber
                        : Colors.grey,
                    size: 24,
                  );
                }),
                const SizedBox(width: 8),
                Text(
                  '${rating.toStringAsFixed(1)}/10',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 24),

// Watched Status Button
            Obx(() {
              final isAdded = controller.isMovieAdded.value;
              final isWatched = controller.isMovieWatched.value;
              final isUpdating = controller.isUpdatingWatchStatus.value;

              return SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: !isAdded || isUpdating
                      ? null
                      : controller.toggleWatchedStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.grey.shade800,
                    disabledForegroundColor: Colors.white54,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: isUpdating
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                      : Icon(
                    isWatched ? Icons.check_circle : Icons.visibility,
                  ),
                  label: Text(
                    !isAdded
                        ? 'Add to library first'
                        : isWatched
                        ? 'Mark as Unwatched'
                        : 'Mark as Watched',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),

            Text(
              'Movie Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),

            _InfoRow(label: 'Status', value: status),
            _InfoRow(label: 'Release date', value: releaseDate),
            _InfoRow(
              label: 'Runtime',
              value: runtime != null ? '$runtime minutes' : 'Unknown',
            ),
            _InfoRow(
              label: 'Original language',
              value: language.toUpperCase(),
            ),
          ],
        ),
      );
    });
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
