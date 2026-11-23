
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watchlog/presentation/shows/upcoming/widgets/upcoming_watch_card.dart';

import 'package:watchlog/presentation/shows/watch_list/controller/watchlist_controller.dart';

class Upcoming extends GetView<WatchlistController> {
  const Upcoming({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final upcomingEpisodes = controller.upcomingEpisodes;

      if (controller.isLoading.value &&
          upcomingEpisodes.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (upcomingEpisodes.isEmpty) {
        return const Center(
          child: Text('No upcoming episodes.'),
        );
      }

      // Group episodes by air date.
      final groupedEpisodes = <DateTime, List<dynamic>>{};

      for (final episode in upcomingEpisodes) {
        final airDate = episode.airDate;

        if (airDate == null) continue;

        final date = DateTime(
          airDate.year,
          airDate.month,
          airDate.day,
        );

        groupedEpisodes.putIfAbsent(date, () => []);
        groupedEpisodes[date]!.add(episode);
      }

      final sortedDates = groupedEpisodes.keys.toList()
        ..sort();

      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 15,
            right: 15,
            top: 20,
          ),
          child: Column(
            children: [
              for (final date in sortedDates) ...[
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.grey.shade900,
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  child: Text(
                    _formatDate(date),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),

                const SizedBox(height: 15),

                for (final episode in groupedEpisodes[date]!)
                  UpcomingWatchCard(
                    episode: episode,
                  ),

                const SizedBox(height: 15),
              ],
            ],
          ),
        ),
      );
    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    if (date == today) return 'Today';
    if (date == tomorrow) return 'Tomorrow';

    return '${date.day}/${date.month}/${date.year}';
  }
}
