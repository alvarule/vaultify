// Splash Screen to show loading

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:password_manager/utils/animations.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset(animationLoading, width: 50),
      ),
    );
  }
}
