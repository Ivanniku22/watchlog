import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watchlog/presentation/profile/controller/profile_controller.dart';

class Profile extends GetView<ProfileController>{

  const Profile ({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
          'Profile',
          style: Theme.of(context).textTheme.bodyMedium
      ),
    );
  }


}