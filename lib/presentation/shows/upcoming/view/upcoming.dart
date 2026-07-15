import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watchlog/presentation/shows/upcoming/controller/upcoming_controller.dart';

class Upcoming extends GetView<UpcomingController> {
  const Upcoming({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
            Container(
              height: 100,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.grey.shade900,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 3),
                    )
                  ]
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      "https://media.themoviedb.org/t/p/original/fHpKWq9ayzSk8nSwqRuaAUemRKh.jpg",
                      width: 60,
                      height: 72,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          // Show Name
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 1.5,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                                color: Theme.of(context).cardTheme.color,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white, // Border color
                                  width: 1,
                                )
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4.0 , right: 2.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      "JUJUTSU KAISEN",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.chevron_right,
                                    size: 15,
                                  )
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 6,),

                          // Season and Episodes Count
                          RichText(
                            text: TextSpan(
                              children: [

                                TextSpan(
                                  text: "S02 | E10",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),


                          // Episode Title
                          Text(
                            "Shibuya Incident 2",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),

                        ],
                      )
                  ),

                  Column(
                    children: [
                      Flexible(
                        child: Text(
                          "7:30 AM",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          "Miruro",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      )
                    ],
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
