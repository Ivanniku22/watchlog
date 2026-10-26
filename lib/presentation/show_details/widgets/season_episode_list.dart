
import 'package:flutter/material.dart';
import 'package:watchlog/presentation/show_details/widgets/episode_card.dart';

class SeasonEpisodeList extends StatefulWidget {
  final List<dynamic> episodes;

  const SeasonEpisodeList({
    super.key,
    required this.episodes,
  });

  @override
  State<SeasonEpisodeList> createState() => _SeasonEpisodeListState();
}

class _SeasonEpisodeListState extends State<SeasonEpisodeList> {
  static const int batchSize = 20;
  int visibleCount = batchSize;

  @override
  Widget build(BuildContext context) {
    final count = widget.episodes.length < visibleCount
        ? widget.episodes.length
        : visibleCount;

    return Column(
      children: [
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
              child: EpisodeCard(episode: episode),
            );
          },
        ),
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
