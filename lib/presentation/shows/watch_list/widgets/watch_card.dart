
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/watchlist_models/next_episode.dart';
import '../controller/watchlist_controller.dart';

class WatchCard extends StatelessWidget {
  final WatchlistEpisode episode;
  final VoidCallback? onTap;
  final VoidCallback? onMarkWatched;
  final bool isWatched;

  const WatchCard({
    super.key,
    required this.episode,
    this.onTap,
    this.onMarkWatched,
    this.isWatched = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<WatchlistController>();

    final imagePath = episode.stillPath?.isNotEmpty == true
        ? episode.stillPath
        : episode.posterPath;

    final imageUrl = imagePath?.isNotEmpty == true
        ? 'https://image.tmdb.org/t/p/w500$imagePath'
        : null;

    return InkWell(
      onTap: onTap ??
              () => controller.openEpisodeDetails(episode),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.grey.shade900,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Episode still / poster
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: imageUrl != null
                  ? Image.network(
                imageUrl,
                width: 60,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                    width: 60,
                    height: 72,
                    child: Icon(Icons.tv),
                  );
                },
              )
                  : const SizedBox(
                width: 60,
                height: 72,
                child: Icon(Icons.tv),
              ),
            ),

            const SizedBox(width: 12),

            // Show and episode information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Show title - opens Show Details
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      controller.openShowDetails(episode.showId);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 1.5,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 4,
                          right: 2,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                episode.showTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.chevron_right,
                              size: 15,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Season and episode
                  Text(
                    'S${episode.seasonNumber} | E${episode.episodeNumber}',
                    style: theme.textTheme.bodyMedium,
                  ),

                  // Episode title
                  Flexible(
                    child: Text(
                      episode.episodeTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 4),

            // Mark as watched
            // Mark as watched
            IconButton(
              onPressed: onMarkWatched,
              tooltip: 'Mark as watched',
              icon: Container(
                width: 27,
                height: 27,
                decoration: BoxDecoration(
                  color: isWatched ? Colors.green : Colors.grey.shade600,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
