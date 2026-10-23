
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watchlog/presentation/show_details/controller/show_details_controller.dart';

class ShowDetailsView extends GetView<ShowDetailsController> {
  const ShowDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final show = controller.show;

    return Scaffold(
      body: CustomScrollView(
        slivers: [

          SliverAppBar(
            expandedHeight: 200,
            pinned: false,
            automaticallyImplyLeading: false,
            elevation: 0,
            backgroundColor: Colors.transparent,

            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Cover image
                  Positioned.fill(
                    child: Image.network(
                      'https://image.tmdb.org/t/p/w780${controller.show.backdropPath}',
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Slight dark overlay
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                  ),

                  // Buttons over the image
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 5,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Down button
                          IconButton(
                            onPressed: () => Get.back(),
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),

                          // Three-dot menu
                          PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.more_horiz,
                              color: Colors.white,
                              size: 25,
                            ),
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'watchlist',
                                child: Text('Add to watchlist'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Show title , episode, duration and genres

                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Show title
                          Text(
                            controller.show.name,
                            maxLines: 2,
                            overflow:  TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Seasons, episodes, and genres

                          Obx(() {
                            if (controller.isLoadingDetails.value) {
                              // Loading skeleton
                              Widget skeletonBar(double width) {
                                return Container(
                                  width: width,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(6),
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

                            final details = controller.showDetails.value;

                            if (details == null) {
                              return const SizedBox.shrink();
                            }

                            final seasons = details['number_of_seasons'];
                            final episodes = details['number_of_episodes'];

                            final genres = (details['genres'] as List<dynamic>?)
                                ?.map((genre) => genre['name'] as String)
                                .toList() ??
                                [];

                            return Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                if (seasons != null) Text('$seasons Seasons •', style:  TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white
                                ),),
                                if (episodes != null) Text('$episodes Episodes •', style:  TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white
                                ),),
                                ...genres.map((genre) => Text(genre, style:  TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white
                                ),)),
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

          // Body Content
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
