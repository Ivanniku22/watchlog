
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watchlog/presentation/episodes/controller/episode_progress_controller.dart';

class EpisodeCard extends StatefulWidget {
  final Map<String, dynamic> episode;
  final VoidCallback onTap;
  final int showId;
  final String showTitle;

   const EpisodeCard({
    super.key,
    required this.episode,
     required this.onTap,
     required this.showId,
     required this.showTitle,
  });

  @override
  State<EpisodeCard> createState() => _EpisodeCardState();
}

class _EpisodeCardState extends State<EpisodeCard> {
  final EpisodeProgressController progressController =
  Get.find<EpisodeProgressController>();

  @override
  void initState() {
    super.initState();

    final seasonNumber = widget.episode['season_number'] as int;
    final episodeNumber = widget.episode['episode_number'] as int;

    progressController.loadEpisodeStatus(
      showId: widget.showId,
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.episode['name'] as String? ?? 'Untitled Episode';
    final episodeNumber = widget.episode['episode_number'] ?? '?';
    final seasonNumber = widget.episode['season_number'] ?? '?';
    final stillPath = widget.episode['still_path'] as String?;

    final imageUrl = stillPath != null && stillPath.isNotEmpty
        ? 'https://image.tmdb.org/t/p/w300$stillPath'
        : null;

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 100,
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
                width: 60,
                height: 72,
                fit: BoxFit.cover,
                cacheWidth: 120,
                cacheHeight: 144,
                errorBuilder: (_, _, _) => _imagePlaceholder(),
              )
                  : _imagePlaceholder(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'S$seasonNumber • E$episodeNumber',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Obx(() {
              final isWatched = progressController.isWatched(
                showId: widget.showId,
                seasonNumber: widget.episode['season_number'] as int,
                episodeNumber: widget.episode['episode_number'] as int,
              );

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      progressController.toggleWatched(
                        showId: widget.showId,
                        showTitle: widget.showTitle,
                        seasonNumber: widget.episode['season_number'] as int,
                        episodeNumber: widget.episode['episode_number'] as int,
                        episodeTitle:
                        widget.episode['name'] as String? ?? 'Untitled Episode',
                      );
                    },
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isWatched
                            ? const Color(0xFF67C600)
                            : Colors.grey.shade300,
                      ),
                      child: Icon(
                        Icons.check,
                        size: 20,
                        color: isWatched
                            ? Colors.white
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isWatched ? 'Watched' : 'Unwatched',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 60,
      height: 72,
      color: Colors.grey.shade800,
      child: const Icon(
        Icons.live_tv,
        color: Colors.white54,
      ),
    );
  }
}
