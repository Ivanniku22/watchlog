import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watchlog/presentation/explore/controller/explore_controller.dart';
import 'package:watchlog/presentation/explore/widgets/filters.dart';

import '../../../data/trending_shows_data.dart';

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

              SizedBox(height: 15,),

              // Recommendations
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
                    'Trending Shows',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),


              SizedBox(height: 10,),

              //Trending Shows Grid view
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: trendingShows.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 3,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index){
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      trendingShows[index].poster,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),

              SizedBox(height: 10,),
            ],
          ),
        ),
      ),
    );
  }

}