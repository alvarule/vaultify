// Splash Screen to show loading

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:password_manager/utils/animations.dart';
import 'package:password_manager/utils/images.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 244, 247),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              backgroundColor: Colors.transparent,
              backgroundImage: AssetImage(logo),
              radius: 60,
            ),
            const SizedBox(height: 60),
            Lottie.asset(
              animationLoadingLight,
              width: 50,
            ),
          ],
        ),
      ),
    );
  }
}
