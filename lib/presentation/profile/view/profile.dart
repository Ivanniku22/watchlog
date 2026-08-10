import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watchlog/presentation/profile/controller/profile_controller.dart';

class Profile extends GetView<ProfileController>{

  const Profile ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [


            // ─────────────────────────────
            // Cover image
            // ─────────────────────────────
            SliverAppBar(
              expandedHeight: 200,
              pinned: false,
              automaticallyImplyLeading: false,
              elevation: 0,
              backgroundColor: Colors.transparent,
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Bell
                      Container(
                        width: 35,
                        height: 35,
                        decoration: const BoxDecoration(
                          color: Colors.yellow,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.notifications_none_outlined,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                      ),


                      // Three dots
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.more_horiz,
                          color: Colors.white60,
                          size: 25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],


              flexibleSpace: FlexibleSpaceBar(
                background: Image.network(
                  'https://static.zerochan.net/86.Eighty-Six.full.3740349.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // ─────────────────────────────
            // Content
            // ─────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Title',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Your content goes here.',
                    ),

                    const SizedBox(height: 500),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


}