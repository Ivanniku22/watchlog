
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watchlog/presentation/episodes/controller/episode_progress_controller.dart';

class EpisodeCard extends StatelessWidget {
  final Map<String, dynamic> episode;
  final VoidCallback onTap;

   EpisodeCard({
    super.key,
    required this.episode,
     required this.onTap,
  });

  final EpisodeProgressController progressController =
  Get.find<EpisodeProgressController>();

  @override
  Widget build(BuildContext context) {
    final name = episode['name'] as String? ?? 'Untitled Episode';
    final episodeNumber = episode['episode_number'] ?? '?';
    final seasonNumber = episode['season_number'] ?? '?';
    final stillPath = episode['still_path'] as String?;
    final episodeId = episode['id'] as int;

    final imageUrl = stillPath != null && stillPath.isNotEmpty
        ? 'https://image.tmdb.org/t/p/w300$stillPath'
        : null;

    return InkWell(
      onTap: onTap,
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
              final isWatched =
              progressController.isWatched(episodeId);

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      progressController.toggleWatched(episodeId);
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
