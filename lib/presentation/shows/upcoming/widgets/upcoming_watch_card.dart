// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:watchlog/data/models/upcoming_show_model.dart';

class UpcomingWatchCard extends StatefulWidget {

  final UpcomingShow upcomingShow;
  const UpcomingWatchCard({super.key , required this.upcomingShow});

  @override
  State<UpcomingWatchCard> createState() => _UpcomingWatchCardState();
}

class _UpcomingWatchCardState extends State<UpcomingWatchCard> {
  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
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
                child:

                // CachedNetworkImage(
                //   imageUrl: widget.upcomingShow.poster,
                //   fit: BoxFit.cover,
                //   memCacheWidth: 300,
                //   placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                //   errorWidget: (context, url, error) => const Icon(Icons.error),
                // ),


                Image.network(
                  widget.upcomingShow.poster,
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
                                 widget.upcomingShow.title,
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
                              text: "${widget.upcomingShow.episode} | ${widget.upcomingShow.season}",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),


                      // Episode Title
                      Flexible(
                        child: Text(
                          widget.upcomingShow.episodeTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),

                    ],
                  )
              ),

              Column(
                children: [
                  Flexible(
                    child: Text(
                      widget.upcomingShow.time,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      widget.upcomingShow.studio,
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
        SizedBox(height: 5,)
      ],
    );
  }
}
