import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watchlog/presentation/explore/controller/explore_controller.dart';
import 'package:watchlog/presentation/explore/widgets/filters.dart';

class Explore extends GetView<ExploreController>{

  const Explore({super.key});



  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
          child: Column(
            children: [
              // Search Field
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
              ),

              SizedBox(height: 10,),

              //Filters
              Filters(),
            ],
          ),
        ),
      ),
    );
  }

}