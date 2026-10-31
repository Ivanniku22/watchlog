import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../episodes/controller/episode_progress_controller.dart';
import '../controller/episode_details_controller.dart';

class EpisodeDetailsView extends GetView<EpisodeDetailsController> {
  const EpisodeDetailsView({super.key});

  @override

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDark
          ? Colors.transparent
          : Colors.grey.shade100,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 56,
        titleSpacing: 0,
        leadingWidth: 56,

        title: Row(
          children: [
            // Down button
            IconButton(
              onPressed: Get.back,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isDark ? Colors.white : Colors.black87,
                size: 30,
              ),
            ),

            // Centered progress indicator in remaining space
            Expanded(
              child: Center(
                child: Obx(() {
                  final currentIndex = controller.currentIndex.value;
                  final total = controller.totalEpisodes;

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (slot) {
                      final index = currentIndex + slot - 2;

                      if (index < 0 || index >= total) {
                        return const SizedBox(width: 16);
                      }

                      final distance =
                      (index - currentIndex).abs();
                      final isCurrent = index == currentIndex;

                      return GestureDetector(
                        onTap: () =>
                            controller.changeEpisode(index),
                        child: AnimatedContainer(
                          duration:
                          const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 3,
                          ),
                          width: isCurrent ? 20 : 10,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? Theme.of(context).colorScheme.primary
                                : (isDark ? Colors.white : Colors.black).withValues(
                              alpha: distance == 1 ? 0.5 : 0.2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ),
            ),

            // Balancing space on the right
            const SizedBox(width: 56),
          ],
        ),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;

          if (velocity < 0) {
            controller.nextEpisode();
          } else if (velocity > 0) {
            controller.previousEpisode();
          }
        },
        child: Obx(() {
          final episode = controller.episode;
          final theme = Theme.of(context);
          final colors = theme.colorScheme;

          final stillPath = episode['still_path'] as String?;
          final airDate = episode['air_date'] as String?;
          final overview = episode['overview'] as String? ?? '';
          final rating =
              (episode['vote_average'] as num?)?.toDouble() ?? 0;
          final runtime = episode['runtime'] as int?;
          final episodeId = episode['id'] as int;

          final progressController =
          Get.find<EpisodeProgressController>();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top spacing for the transparent AppBar.
                const SizedBox(height: 90),


                // Cinematic episode still with title overlay.
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (stillPath != null && stillPath.isNotEmpty)
                        Image.network(
                          'https://image.tmdb.org/t/p/w1280$stillPath',
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: colors.surfaceContainerHighest,
                            child: Icon(
                              Icons.movie_outlined,
                              size: 56,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        )
                      else
                        Container(
                          color: colors.surfaceContainerHighest,
                          child: Icon(
                            Icons.movie_outlined,
                            size: 56,
                            color: colors.onSurfaceVariant,
                          ),
                        ),


                      // Gradient behind episode title.
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black54,
                              Colors.black87,
                            ],
                            stops: [0.35, 0.7, 1],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 16,
                        left: 16,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            Get.toNamed(
                              AppRoutes.showDetails,
                              arguments: controller.show,
                            );
                          },
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 220),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade800.withValues(alpha: 0.9),
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    controller.show.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),


                      // Previous episode button
                      Positioned(
                        left: 12,
                        top: 0,
                        bottom: 20,
                        child: Center(
                          child: Obx(() {
                            final isFirst = controller.currentIndex.value == 0;

                            return Material(
                              color: isFirst
                                  ? Colors.black.withValues(alpha: 0.2)
                                  : Colors.black.withValues(alpha: 0.45),
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: isFirst ? null : controller.previousEpisode,
                                child: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: Center(
                                    child: Icon(
                                      Icons.chevron_left_rounded,
                                      size: 30,
                                      color: isFirst ? Colors.white38 : Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      // Next episode button
                      Positioned(
                        right: 12,
                        top: 0,
                        bottom: 20,
                        child: Center(
                          child: Obx(() {
                            final isLast = controller.currentIndex.value ==
                                controller.totalEpisodes - 1;

                            return Material(
                              color: isLast
                                  ? Colors.black.withValues(alpha: 0.2)
                                  : Colors.black.withValues(alpha: 0.45),
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: isLast ? null : controller.nextEpisode,
                                child: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: Center(
                                    child: Icon(
                                      Icons.chevron_right_rounded,
                                      size: 30,
                                      color: isLast ? Colors.white38 : Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 22,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'S${episode['season_number']} · E${episode['episode_number']}',
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                      color: Colors.white70,
                                      letterSpacing: 1.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    episode['name'] ??
                                        'Untitled Episode',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),

                            // TV Time-style watched toggle.
                            Obx(() {
                              final watched =
                              progressController.isWatched(episodeId);

                              return GestureDetector(
                                onTap: () {
                                  progressController
                                      .toggleWatched(episodeId);
                                },
                                child: AnimatedContainer(
                                  duration:
                                  const Duration(milliseconds: 200),
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: watched
                                        ? Colors.green
                                        : Colors.grey.shade600,
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 23,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Episode metadata.
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        episode['name'] ?? 'Untitled Episode',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        'S${episode['season_number']} · E${episode['episode_number']}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 20,
                        runSpacing: 12,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (airDate != null && airDate.isNotEmpty)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 16,
                                  color: colors.onSurfaceVariant,
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  airDate,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          if (runtime != null && runtime > 0)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 17,
                                  color: colors.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$runtime min',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // TMDB rating.
                      if (rating > 0)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              rating.toStringAsFixed(1),
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: List.generate(
                                    5,
                                        (index) => Icon(
                                      Icons.star_rounded,
                                      size: 16,
                                      color: index <
                                          (rating / 2).round()
                                          ? Colors.amber
                                          : colors.outlineVariant,
                                    ),
                                  ),
                                ),
                                Text(
                                  '/ 10 · TMDB',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                      const SizedBox(height: 24),
                      Divider(color: colors.outlineVariant),
                      const SizedBox(height: 20),

                      // Episode overview.
                      Text(
                        'About this episode',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        overview.isNotEmpty
                            ? overview
                            : 'No episode overview available.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.7,
                          color: colors.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 32),
                      Center(
                        child: Text(
                          'WATCHLOG · EPISODE DETAILS',
                          style: theme.textTheme.labelSmall?.copyWith(
                            letterSpacing: 2,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

}
