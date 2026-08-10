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
            // Cover image + buttons
            // ─────────────────────────────
            SliverAppBar(
              expandedHeight: 200,
              pinned: false,
              automaticallyImplyLeading: false,
              elevation: 0,
              backgroundColor: Colors.transparent,

              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    // Cover image
                    Positioned.fill(
                      child: Image.network(
                        'https://static.zerochan.net/86.Eighty-Six.full.3740349.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),

                    // Buttons over the image
                    SafeArea(
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 5,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
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
                                  padding: EdgeInsets.zero,
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
                                  color: Colors.black,
                                  size: 25,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
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
                     Text(
                      'Your Title',
                        style: Theme.of(context).textTheme.bodyMedium,
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'Your content goes here.',
                      style: Theme.of(context).textTheme.bodyMedium,
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