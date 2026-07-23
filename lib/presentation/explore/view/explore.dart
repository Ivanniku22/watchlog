import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watchlog/data/added_shows_data.dart';
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

             // Trending Shows Grid
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
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.network(
                            trendingShows[index].poster,
                            fit: BoxFit.cover,
                          ),
                        ),

                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              // TODO: Add show
                            },
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFFFFD700),
                                )
                              ),
                              child: const Icon(
                                Icons.add,
                                color: const Color(0xFFFFD700),
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              //See more button
              GestureDetector(
                onTap: () {
                  // TODO: Handle tap
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'See More',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),


              SizedBox(height: 20,),

              // Recommendations 2
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
                    'Most Added Show',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),

              SizedBox(height: 10,),

              //Added Shows Grid
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: addedShows.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 3,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index){
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.network(
                            addedShows[index].poster,
                            fit: BoxFit.cover,
                          ),
                        ),

                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              // TODO: Add show
                            },
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xFFFFD700),
                                  )
                              ),
                              child: const Icon(
                                Icons.add,
                                color: const Color(0xFFFFD700),
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              //See more button
              GestureDetector(
                onTap: () {
                  // TODO: Handle tap
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'See More',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),

              SizedBox(height: 30,),
            ],
          ),
        ),
      ),
    );
  }

}