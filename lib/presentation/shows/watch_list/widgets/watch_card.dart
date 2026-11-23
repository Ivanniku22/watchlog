
import 'package:flutter/material.dart';

import '../../../../data/models/watchlist_models/next_episode.dart';


class WatchCard extends StatelessWidget {
  final WatchlistEpisode episode;
  final VoidCallback? onTap;
  final VoidCallback? onMarkWatched;

  const WatchCard({
    super.key,
    required this.episode,
    this.onTap,
    this.onMarkWatched,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = episode.stillPath?.isNotEmpty == true
        ? episode.stillPath
        : episode.posterPath;

    final imageUrl = imagePath?.isNotEmpty == true
        ? 'https://image.tmdb.org/t/p/w500$imagePath'
        : null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
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
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: imageUrl != null
                  ? Image.network(
                imageUrl,
                width: 100,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const SizedBox(
                  width: 100,
                  child: Icon(Icons.movie, size: 40),
                ),
              )
                  : const SizedBox(
                width: 100,
                child: Icon(Icons.movie, size: 40),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    episode.showTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'S${episode.seasonNumber} E${episode.episodeNumber}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    episode.episodeTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            IconButton(
              onPressed: onMarkWatched,
              icon: const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
