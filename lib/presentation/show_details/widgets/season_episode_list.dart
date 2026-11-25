
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:watchlog/presentation/episodes/controller/episode_progress_controller.dart';
import 'package:watchlog/presentation/show_details/widgets/episode_card.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/models/tmdb_models/popular.dart';

class SeasonEpisodeList extends StatefulWidget {
  final List<dynamic> episodes;
  final TvShow show;
  final int seasonNumber;

  const SeasonEpisodeList({
    super.key,
    required this.episodes,
    required this.show,
    required this.seasonNumber,
  });

  @override
  State<SeasonEpisodeList> createState() => _SeasonEpisodeListState();
}

class _SeasonEpisodeListState extends State<SeasonEpisodeList> {
  static const int batchSize = 20;

  int visibleCount = batchSize;

  final EpisodeProgressController progressController =
  Get.find<EpisodeProgressController>();

  @override
  Widget build(BuildContext context) {
    final count = widget.episodes.length < visibleCount
        ? widget.episodes.length
        : visibleCount;

    final episodeNumbers = <int>[];
    final episodeTitles = <int, String>{};

    for (final item in widget.episodes) {
      final episode = Map<String, dynamic>.from(item as Map);
      final number = (episode['episode_number'] as num?)?.toInt();

      if (number == null) continue;

      episodeNumbers.add(number);
      episodeTitles[number] =
          episode['name'] as String? ?? 'Untitled Episode';
    }

    return Column(
      children: [
        // Mark entire season as watched button.
        Obx(() {
          final isLoading = progressController.markingSeasonNumbers
              .contains(widget.seasonNumber);

          final allWatched = episodeNumbers.isNotEmpty &&
              episodeNumbers.every(
                    (number) => progressController.isWatched(
                  showId: widget.show.id,
                  seasonNumber: widget.seasonNumber,
                  episodeNumber: number,
                ),
              );

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading || allWatched
                    ? null
                    : () {
                  progressController.markSeasonWatched(
                    showId: widget.show.id,
                    showTitle: widget.show.name,
                    seasonNumber: widget.seasonNumber,
                    episodeNumbers: episodeNumbers,
                    episodeTitles: episodeTitles,
                  );
                },
                icon: isLoading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : Icon(
                  allWatched
                      ? Icons.check_circle
                      : Icons.done_all,
                ),
                label: Text(
                  isLoading
                      ? 'Marking season...'
                      : allWatched
                      ? 'Season Watched'
                      : 'Mark Season as Watched',
                ),
              ),
            ),
          );
        }),

        // Existing individual episode list.
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: count,
          itemBuilder: (context, index) {
            final episode = Map<String, dynamic>.from(
              widget.episodes[index] as Map,
            );

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: EpisodeCard(
                episode: episode,
                showId: widget.show.id,
                showTitle: widget.show.name,
                onTap: () {
                  Get.toNamed(
                    AppRoutes.episodeDetails,
                    arguments: {
                      'episode': episode,
                      'show': widget.show,
                      'episodes': widget.episodes,
                    },
                  );
                },
              ),
            );
          },
        ),

        // Existing Load more button.
        if (visibleCount < widget.episodes.length)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextButton(
              onPressed: () {
                setState(() {
                  visibleCount += batchSize;
                });
              },
              child: const Text('Load more'),
            ),
          ),
      ],
    );
  }
}
