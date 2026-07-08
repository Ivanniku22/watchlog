import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watchlog/presentation/upcoming/controller/upcoming_controller.dart';

class Upcoming extends GetView<UpcomingController>{
  const Upcoming ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
            "Upcoming",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w300,
                fontFamily: 'Inter',
                fontSize: 20,
            ),
        ),

      ),
    );
  }


}