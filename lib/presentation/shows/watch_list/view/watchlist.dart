
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/watchlist_controller.dart';
import '../widgets/watch_card.dart';

class Watchlist extends GetView<WatchlistController> {
  const Watchlist({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return Center(
          child: Text(controller.errorMessage.value),
        );
      }

      final shows = controller.myShows;

      if (shows.isEmpty) {
        return const Center(
          child: Text('Your watchlist is empty.'),
        );
      }

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
              _sectionTitle(context, 'Your Shows'),
              const SizedBox(height: 10),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: shows.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: WatchCard(show: shows[index]),
                  );
                },
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Container(
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
        title,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
