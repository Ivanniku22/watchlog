import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watchlog/presentation/upcoming/view/upcoming.dart';
import 'package:watchlog/presentation/watch_list/view/watchList.dart';

import '../controller/home_view_model.dart';

class HomeView extends GetView<HomeViewModel> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(5),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Theme.of(context).colorScheme.onPrimary,
                    unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                    labelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  tabs: [
                  Text(
                      'Watch List',
                      style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                      'Upcoming',
                      style: Theme.of(context).textTheme.titleLarge ,
                  ),

                ]),
              ),
            ),
          ),
          body: TabBarView(
              children: [
              Watchlist(),
              Upcoming()
          ]),
        ));
  }
}