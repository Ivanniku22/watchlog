import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watchlog/presentation/explore/controller/explore_controller.dart';

class Explore extends GetView<ExploreController>{

  const Explore({super.key});



  @override
  Widget build(BuildContext context) {

    final List<String> filters = [
      "FEED",
      "DISCOVER",
      "GROUPS",
      "ACTIVITY"
    ];


    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
          child: Column(
            children: [
              TextField(
                style: Theme.of(context).textTheme.bodySmall,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey
                    )
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

}