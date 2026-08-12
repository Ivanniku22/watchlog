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

                    // Slight dark overlay
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.5),
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

                    // User Image
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          bottom: 10,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Profile image
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                                image: const DecorationImage(
                                  image: NetworkImage(
                                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQjy2s4zrQ_ZSf87QkQ6BciADKKx6_Qy_r3gBkoyKSBD_LAiz6JBphvmhrw&s=10',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Edit button
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                side: const BorderSide(
                                  color: Colors.white,
                                  width: 1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                  "Edit",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),

                            ),
                          ],
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
                    // Followers, Following and Comments Box
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatBox(0, 'Following', context),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatBox(0, 'Followers', context),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatBox(0, 'Comments', context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Stats Heading with right arrow
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Stats',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.keyboard_arrow_right_outlined,
                            color: Theme.of(context).iconTheme.color,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Horizontally scrolling stats
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 150,
                            child: _buildWatchBox(
                              1,
                              2,
                              100,
                              "TV Time",
                              context,
                            ),
                          ),

                          const SizedBox(width: 20),

                          SizedBox(
                            width: 200,
                            child: _buildWatchBox(
                              1,
                              2,
                              100,
                              "Episodes Watched",
                              context,
                            ),
                          ),
                        ],
                      ),
                    ),
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



Widget _buildStatBox(int number, String label, BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Colors.grey.shade300,
      ),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          number.toString(),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    ),
  );
}



Widget _buildWatchBox(int month, int day , int hours, String label, BuildContext context) {
  return Column(
    children: [
      // Top box
      Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: Row(
          spacing: 2,
          children: [
            IconButton(
                onPressed: (){},
                icon: Icon(Icons.live_tv_outlined)
            ),

            SizedBox(width: 10,),

            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
      // Below box
      Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7.0),
          child: Row(
            spacing: 10,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    month.toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Month",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    day.toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Day",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    hours.toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Hours",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  );
}