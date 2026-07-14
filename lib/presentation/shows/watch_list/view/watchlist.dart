import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watchlog/data/show_data.dart';
import 'package:watchlog/presentation/shows/watch_list/controller/watchlist_controller.dart';
import 'package:watchlog/presentation/shows/watch_list/widgets/watch_card.dart';

import '../../../../data/havent_watched_data.dart';

class Watchlist extends GetView<WatchlistController> {
  const Watchlist({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 20.0),
        child: Column(
          children: [
          // Watch List Title
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.grey.shade900,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                child: Text(
                  'Watch Next',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),

            SizedBox(height: 10,),

            // Watch Cards
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: shows.length,
              itemBuilder: (context,index){
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: WatchCard(show: shows[index]),
                );
              }),

            SizedBox(height: 10,),

            // Haven't Watched Cards Title
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.grey.shade900,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                child: Text(
                  "Haven't Watched Yet",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),

            SizedBox(height: 10,),

            // Haven't Watched Cards
            ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: haventWatched.length,
                itemBuilder: (context,index){
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: WatchCard(show: haventWatched[index]),
                  );
                }),

          ],
        ),
      ),
    );
  }
}
