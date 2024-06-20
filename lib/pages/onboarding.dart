// User Onboarding Page

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:password_manager/pages/auth.dart';
import 'package:password_manager/utils/images.dart';
import 'package:password_manager/widgets/my_text.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // Appbar
      appBar: AppBar(
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
          MyText(
            text: "Password Manage\nFrom Anywhere",
            textAlign: TextAlign.center,
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).highlightColor,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: MyText(
              text:
                  "Keep your passwords in a secure private vault and simply access them with one click",
              textAlign: TextAlign.center,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).hintColor,
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
                backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).focusColor),
              ),
              child: MyText(
                text: "Get Started",
                fontSize: 20,
                color: Theme.of(context).focusColor,
              ),
            ),
          ),

          // Button -> Login
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyText(
                text: "I have an account!",
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).highlightColor,
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AuthPage(isLogin: true),
                    ),
                  );
                },
                child: MyText(
                  text: "Login",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
