import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watchlog/presentation/watch_list/controller/watchList_controller.dart';

class Watchlist extends GetView<WatchlistController>{
  const Watchlist({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Watch List",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w300,
            fontFamily: 'Inter',
            fontSize: 20,
          ),
        ),

      ),
    );
  }


}