import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watchlog/presentation/upcoming/view/upcoming.dart';
import 'package:watchlog/presentation/watch_list/view/watchlist.dart';

import '../controller/home_view_model.dart';

class HomeView extends GetView<HomeViewModel> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedIndex = controller.selectedIndex.value;

      if (selectedIndex == 0) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              bottom: _showsTabBar(context),
            ),
            body: const TabBarView(children: [Watchlist(), Upcoming()]),
            bottomNavigationBar: _BottomNav(
              selectedIndex: selectedIndex,
              onDestinationSelected: controller.changeTab,
            ),
          ),
        );
      }

      return Scaffold(
        body: _NavPage(
          icon: _navPageIcons[selectedIndex],
          title: controller.selectedTitle,
        ),
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

class _NavPage extends StatelessWidget {
  const _NavPage({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: colorScheme.primary),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

const _navPageIcons = [
  Icons.tv_rounded,
  Icons.movie_rounded,
  Icons.search_rounded,
  Icons.person_rounded,
];
