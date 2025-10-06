import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'auth/auth_page.dart';
import 'main_page.dart';

class AppNavigator extends StatelessWidget {
  const AppNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();

    return Obx(() {
      if (authController.isAuthenticated.value) {
        return const MainPage();
      } else {
        return const AuthPage();
      }
    });
  }
}
