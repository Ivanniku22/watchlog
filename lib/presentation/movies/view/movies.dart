import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watchlog/presentation/movies/controller/movies_controller.dart';

import '../../movies/upcoming/view/upcoming.dart';
import '../../movies/watch_list/view/watchlist.dart';

class Movies extends GetView<MoviesController>{
  const Movies ({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(bottom: _showsTabBar(context)),
          body: TabBarView(children: [Watchlist(),  Upcoming()]),
        ),
    );
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