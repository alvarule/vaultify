// User Onboarding Page

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:password_manager/pages/auth.dart';
import 'package:password_manager/utils/colors.dart';
import 'package:password_manager/utils/images.dart';
import 'package:password_manager/widgets/my_text.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: gray,

      // Appbar
      appBar: AppBar(
        surfaceTintColor: gray,
        backgroundColor: gray,
      ),

      // Body
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Onboarding Image
          SvgPicture.asset(
            onboardingImg,
          ),

          // Onboarding Text
          const MyText(
            text: "Password Manage\nFrom Anywhere",
            textAlign: TextAlign.center,
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: secondary,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: MyText(
              text:
                  "Keep your passwords in a secure private vault and simply access them with one click",
              textAlign: TextAlign.center,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: secondary60,
            ),
          ),

          // Button -> Get Started
          Container(
            width: double.infinity,
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AuthPage(isLogin: false),
                  ),
                );
              },
              style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsets>(
                  const EdgeInsets.symmetric(vertical: 12),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(primary),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                foregroundColor: MaterialStateProperty.all<Color>(white),
              ),
              child: const MyText(
                text: "Get Started",
                fontSize: 20,
                color: white,
              ),
            ),
          ),

          // Button -> Login
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const MyText(
                text: "I have an account!",
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: secondary,
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AuthPage(isLogin: true),
                    ),
                  );
                },
                child: const MyText(
                  text: "Login",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: primary,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
