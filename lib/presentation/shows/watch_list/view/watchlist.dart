import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watchlog/data/show_data.dart';
import 'package:watchlog/presentation/shows/watch_list/controller/watchlist_controller.dart';
import 'package:watchlog/presentation/shows/watch_list/widgets/watch_card.dart';

class Watchlist extends GetView<WatchlistController> {
  const Watchlist({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 20.0),
        child: Column(
          children: [
        
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: shows.length,
              itemBuilder: (context,index){
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: WatchCard(show: shows[index]),
                );
              })
            ,
          ],
        ),
      ),
    );
  }
}
