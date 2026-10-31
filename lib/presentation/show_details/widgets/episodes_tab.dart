
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watchlog/presentation/show_details/controller/show_details_controller.dart';
import 'package:watchlog/presentation/show_details/widgets/season_episode_list.dart';

class EpisodesTab extends GetView<ShowDetailsController> {
  const EpisodesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingDetails.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final details = controller.showDetails.value;
      if (details == null) {
        return const Center(child: Text('Unable to load seasons.'));
      }

      final seasons = details['seasons'] as List<dynamic>? ?? [];
      final regularSeasons = seasons.where((season) {
        return (season['season_number'] as int? ?? 0) > 0;
      }).toList();

      if (regularSeasons.isEmpty) {
        return const Center(child: Text('No seasons available.'));
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: regularSeasons.length,
        itemBuilder: (context, index) {
          final season =
          Map<String, dynamic>.from(regularSeasons[index] as Map);
          final seasonNumber = season['season_number'] as int? ?? 0;
          final episodeCount = season['episode_count'] as int? ?? 0;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            clipBehavior: Clip.antiAlias,
            child: ExpansionTile(
              initiallyExpanded: false,
              onExpansionChanged: (isExpanded) {
                if (isExpanded) {
                  controller.fetchSeasonDetails(seasonNumber);
                }
              },
              title: Text(
                'Season $seasonNumber',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text('$episodeCount Episodes'),
              children: [
                Obx(() {
                  if (controller.loadingSeasonNumbers
                      .contains(seasonNumber)) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    );
                  }

                  final loadedSeason = controller.seasonDetails
                      .where((item) =>
                  item['season_number'] == seasonNumber)
                      .firstOrNull;

                  if (loadedSeason == null) {
                    return const SizedBox.shrink();
                  }

                  final episodes =
                      loadedSeason['episodes'] as List<dynamic>? ?? [];

                  if (episodes.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No episodes available.'),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                    child: SeasonEpisodeList(episodes: episodes),
                  );
                }),
              ],
            ),
          );
        },
      );
    });
  }
}
