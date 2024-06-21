// Splash Screen to show loading

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:password_manager/utils/animations.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(context) {
    // Retrieve the current brightness of the system.
    final Brightness currentBrightness = MediaQuery.of(context).platformBrightness;
    final bool isLightMode = currentBrightness == Brightness.light;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Lottie.asset(
          isLightMode ? animationLoadingLight : animationLoadingDark,
          width: 50,
        ),
      ),
    );
  }
}
