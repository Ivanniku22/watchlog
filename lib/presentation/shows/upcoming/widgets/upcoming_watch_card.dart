
import 'package:flutter/material.dart';

import '../../../../data/models/watchlist_models/next_episode.dart';

class UpcomingWatchCard extends StatelessWidget {
  final WatchlistEpisode episode;

  const UpcomingWatchCard({
    super.key,
    required this.episode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final posterUrl = episode.posterPath != null &&
        episode.posterPath!.isNotEmpty
        ? 'https://image.tmdb.org/t/p/w200${episode.posterPath}'
        : null;

    final airDate = episode.airDate;

    return Column(
      children: [
        Container(
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
                spreadRadius: 0,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Poster
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: posterUrl != null
                    ? Image.network(
                  posterUrl,
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
                    // Show name
                    Container(
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

                    const SizedBox(height: 6),

                    // Season and episode number
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

              const SizedBox(width: 8),

              // Air date
              SizedBox(
                width: 65,
                child: Text(
                  airDate != null
                      ? '${airDate.day}/${airDate.month}/${airDate.year}'
                      : 'TBA',
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 5),
      ],
    );
  }
}
