import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watchlog/data/upcoming_show_data.dart';
import 'package:watchlog/presentation/shows/upcoming/controller/upcoming_controller.dart';
import 'package:watchlog/presentation/shows/upcoming/widgets/upcoming_watch_card.dart';

class Upcoming extends GetView<UpcomingController> {
  const Upcoming({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 20.0),
        child: Column(
          children: [

            // Week name text
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
                  'Tomorrow',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),

            SizedBox(height: 15,),

            // Watch Card
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: upcomingShows.length,
              itemBuilder: (context , index) {
                return UpcomingWatchCard(upcomingShow: upcomingShows[index]);
              }
            ),


          ],
        ),
      ),
    );
  }
}
