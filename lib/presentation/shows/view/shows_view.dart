import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watchlog/presentation/shows/upcoming/view/upcoming.dart';
import 'package:watchlog/presentation/shows/watch_list/view/watchlist.dart';
import 'package:watchlog/presentation/explore/view/explore.dart';
import 'package:watchlog/presentation/movies/view/movies.dart';
import 'package:watchlog/presentation/profile/view/profile.dart';

import '../controller/shows_view_model.dart';

class ShowsView extends GetView<ShowsViewModel> {
  const ShowsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedIndex = controller.selectedIndex.value;

      if (selectedIndex == 0) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(bottom: _showsTabBar(context)),
            body: const TabBarView(children: [Watchlist(), Upcoming()]),
            bottomNavigationBar: _BottomNav(
              selectedIndex: selectedIndex,
              onDestinationSelected: controller.changeTab,
            ),
          ),
        );
      }

      final navPages = [
        const SizedBox.shrink(),
        const Movies(),
        const Explore(),
        const Profile(),
      ];

      return Scaffold(
        body: navPages[selectedIndex],
        bottomNavigationBar: _BottomNav(
          selectedIndex: selectedIndex,
          onDestinationSelected: controller.changeTab,
        ),
      );
    });
  }

  PreferredSizeWidget _showsTabBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(5),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: TabBar(
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: 'Watch List'),
            Tab(text: 'Upcoming'),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.tv_outlined),
          selectedIcon: Icon(Icons.tv_rounded),
          label: 'Shows',
        ),
        NavigationDestination(
          icon: Icon(Icons.movie_outlined),
          selectedIcon: Icon(Icons.movie_rounded),
          label: 'Movies',
        ),
        NavigationDestination(
          icon: Icon(Icons.search_outlined),
          selectedIcon: Icon(Icons.search_rounded),
          label: 'Explore',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_outlined),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}

