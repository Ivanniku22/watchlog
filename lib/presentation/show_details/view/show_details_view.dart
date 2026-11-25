
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/show_details_controller.dart';
import '../widgets/about_tab.dart';
import '../widgets/episodes_tab.dart';

class ShowDetailsView extends GetView<ShowDetailsController> {
  const ShowDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 200,
                pinned: false,
                automaticallyImplyLeading: false,
                elevation: 0,
                backgroundColor: Colors.transparent,
                forceElevated: innerBoxIsScrolled,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      // Backdrop image
                      Positioned.fill(
                        child: Image.network(
                          'https://image.tmdb.org/t/p/w780${controller.show.backdropPath ?? ''}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade900,
                            );
                          },
                        ),
                      ),

                      // Dark overlay
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.3),
                        ),
                      ),

                      // Back and menu buttons
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 5,
                          ),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () => Get.back(),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),

                              // Three-dot menu
                              Obx(
                                    () => PopupMenuButton<String>(
                                  icon: const Icon(
                                    Icons.more_horiz,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                  enabled:
                                  !controller.isUpdatingWatchlist.value,
                                  onSelected: (value) {
                                        if (value == 'add') {
                                          controller.addToWatchlist();
                                        } else if (value == 'remove') {
                                          _showRemoveConfirmation(context);
                                        } else if (value == 'unwatch') {
                                          _showUnwatchConfirmation(context);
                                        }
                                      },
                                  itemBuilder: (context) {
                                    if (controller.isShowAdded.value) {
                                      return const [
                                        PopupMenuItem(
                                          value: 'remove',
                                          child: Row(
                                            children: [
                                              Icon(CupertinoIcons.trash, color: Colors.red, size: 19),
                                              SizedBox(width: 10),
                                              Text(
                                                'Remove from Watchlist',
                                                style: TextStyle(color: Colors.red),
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'unwatch',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.restart_alt_rounded,
                                                color: Color(0xFFFFD700),
                                                size: 19,
                                              ),
                                              SizedBox(width: 10),
                                              Text('Unwatch This Show'),
                                            ],
                                          ),
                                        ),
                                      ];
                                    }

                                    return const [
                                      PopupMenuItem(
                                        value: 'remove',
                                        child: Row(
                                          children: [
                                            Icon(
                                              CupertinoIcons.trash,
                                              color: Colors.red,
                                              size: 19,
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              'Remove from Watchlist',
                                              style: TextStyle(color: Colors.red),
                                            ),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'unwatch',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.restart_alt_rounded,
                                              color: Color(0xFFFFD700),
                                              size: 19,
                                            ),
                                            SizedBox(width: 10),
                                            Text('Unwatch This Show'),
                                          ],
                                        ),
                                      ),
                                    ];
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Title and metadata
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.show.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Metadata loading skeleton and details
                              Obx(() {
                                if (controller.isLoadingDetails.value) {
                                  Widget skeletonBar(double width) {
                                    return Container(
                                      width: width,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withValues(
                                          alpha: 0.35,
                                        ),
                                        borderRadius:
                                        BorderRadius.circular(6),
                                      ),
                                    );
                                  }

                                  return Row(
                                    children: [
                                      skeletonBar(65),
                                      const SizedBox(width: 10),
                                      skeletonBar(75),
                                      const SizedBox(width: 10),
                                      skeletonBar(55),
                                    ],
                                  );
                                }

                                final details =
                                    controller.showDetails.value;

                                if (details == null) {
                                  return const SizedBox.shrink();
                                }

                                final seasons =
                                details['number_of_seasons'];

                                final episodes =
                                details['number_of_episodes'];

                                final genres =
                                    (details['genres'] as List<dynamic>?)
                                        ?.map(
                                          (genre) =>
                                      genre['name'] as String,
                                    )
                                        .toList() ??
                                        [];

                                const metadataStyle = TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                );

                                return Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  crossAxisAlignment:
                                  WrapCrossAlignment.center,
                                  children: [
                                    if (seasons != null)
                                      Text(
                                        '$seasons Seasons •',
                                        style: metadataStyle,
                                      ),
                                    if (episodes != null)
                                      Text(
                                        '$episodes Episodes •',
                                        style: metadataStyle,
                                      ),
                                    ...genres.map(
                                          (genre) => Text(
                                        genre,
                                        style: metadataStyle,
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Pinned tabs beneath collapsible header
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarHeaderDelegate(
                  TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor:
                    Theme.of(context).colorScheme.onSurfaceVariant,
                    unselectedLabelColor:
                    Theme.of(context).colorScheme.onSurfaceVariant,
                    labelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: const [
                      Tab(text: 'ABOUT'),
                      Tab(text: 'EPISODES'),
                    ],
                  ),
                  MediaQuery.paddingOf(context).top * 0.7,
                ),
              ),
            ];
          },

          // Tab content
          body: const TabBarView(
            children: [
              AboutTab(),
              EpisodesTab(),
            ],
          ),
        ),

        // Floating bottom watchlist button
        bottomNavigationBar: Obx(() {
          if (controller.isCheckingWatchlist.value) {
            return const SizedBox.shrink();
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: controller.isUpdatingWatchlist.value
                      ? null
                      : controller.isShowAdded.value
                      ? null
                      : controller.addToWatchlist,
                  icon: controller.isUpdatingWatchlist.value
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                      : Icon(
                    controller.isShowAdded.value
                        ? CupertinoIcons.check_mark
                        : CupertinoIcons.add,
                    color: Colors.black,
                  ),
                  label: Text(
                    controller.isUpdatingWatchlist.value
                        ? 'Please wait...'
                        : controller.isShowAdded.value
                        ? 'Added to Watchlist'
                        : 'Add to Watchlist',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    disabledBackgroundColor:
                    const Color(0xFFFFD700),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // Confirmation dialog
  void _showRemoveConfirmation(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('Remove from Watchlist?'),
        content: Text(
          'Are you sure you want to remove '
              '${controller.show.name} from your watchlist?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.removeFromWatchlist();
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showUnwatchConfirmation(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Unwatch This Show?'),
        content: const Text(
          'This will reset all watched episodes for this show '
              'and move it to Plan to Watch. The show will remain '
              'in your watchlist.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.unwatchShow();
            },
            child: const Text(
              'Unwatch',
              style: TextStyle(
                color: Color(0xFFFFD700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Keeps the TabBar pinned beneath the collapsing header.
class _TabBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final double topInset;

  _TabBarHeaderDelegate(this.tabBar, this.topInset);

  @override
  double get minExtent => tabBar.preferredSize.height + topInset;

  @override
  double get maxExtent => minExtent;

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: topInset),
          tabBar,
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_TabBarHeaderDelegate oldDelegate) {
    return oldDelegate.tabBar != tabBar ||
        oldDelegate.topInset != topInset;
  }
}
