// Splash Screen to show loading

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:password_manager/utils/animations.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Lottie.asset(
          ThemeMode.system == ThemeMode.light
              ? animationLoadingLight
              : animationLoadingDark,
          width: 50,
        ),
      ),
    );
  }
}
