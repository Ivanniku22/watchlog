
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/watchlist_models/next_episode.dart';
import '../controller/watchlist_controller.dart';
import '../widgets/watch_card.dart';

class Watchlist extends GetView<WatchlistController> {
  const Watchlist({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(controller.errorMessage.value),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: controller.refreshPage,
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshPage,
        color: const Color(0xFFFFD700),
        backgroundColor: Theme.of(context).cardTheme.color,
        displacement: 45,
        strokeWidth: 2.5,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),

            _buildSection(
              'Currently Watching',
              controller.currentlyWatching,
            ),

            _buildSection(
              'Plan to Watch',
              controller.planToWatch,
            ),

            Obx(() {
              if (controller.currentlyWatching.isEmpty &&
                  controller.planToWatch.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text('Your watchlist is empty.'),
                  ),
                );
              }

              return const SliverToBoxAdapter(
                child: SizedBox(height: 15),
              );
            }),
          ],
        ),
      );
    });
  }

  Widget _buildSection(
      String title,
      List<WatchlistEpisode> episodes,
      ) {
    return Obx(() {
      if (episodes.isEmpty) {
        return const SliverToBoxAdapter(
          child: SizedBox.shrink(),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        sliver: SliverList.builder(
          itemCount: episodes.length + 3,
          itemBuilder: (context, index) {
            // Section heading
            if (index == 0) {
              return _sectionTitle(context, title);
            }

            // Spacing below heading
            if (index == 1) {
              return const SizedBox(height: 10);
            }

            // Bottom spacing
            if (index == episodes.length + 2) {
              return const SizedBox(height: 15);
            }

            // Episode card
            final episode = episodes[index - 2];

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: WatchCard(
                episode: episode,
                onTap: () {
                  controller.openEpisodeDetails(episode);
                },
                onMarkWatched: () {
                  controller.markEpisodeWatched(episode);
                },
              ),
            );
          },
        ),
      );
    });
  }



  Widget _sectionTitle(
      BuildContext context,
      String title,
      ) {
    return Align(
      alignment: Alignment.center,
      child: IntrinsicWidth(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.grey.shade900,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 5,
          ),
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ),
    );
  }


}
