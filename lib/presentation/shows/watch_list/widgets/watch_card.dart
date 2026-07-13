
import 'package:flutter/material.dart';

import '../../../../data/models/show_model.dart';

class WatchCard extends StatefulWidget {

  final Show show;
  const WatchCard({super.key ,required this.show , });

  @override
  State<WatchCard> createState() => _WatchCardState();
}

class _WatchCardState extends State<WatchCard> {
  bool isWatched = false;

  @override
  Widget build(BuildContext context) {
    

    
    return Container(
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
              widget.show.poster,
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
                              widget.show.title,
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
                          text: "${widget.show.season} | ${widget.show.episode}",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),

                        TextSpan(
                          text: widget.show.episodePend,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),


                  // Episode Title
                  Text(
                    widget.show.title,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                ],
              )
          ),


          // Green Check Box
          GestureDetector(
            onTap: () {
              setState(() {
                isWatched = !isWatched;
              });
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isWatched
                    ? const Color(0xFF67C600)
                    : Colors.grey.shade300,
              ),
              child: Icon(
                Icons.check,
                color: isWatched ? Colors.white : Colors.grey.shade600,
              ),
            ),
          )
        ],
      ),
    );
  }
}
