// Base Screen

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:password_manager/pages/home.dart';
import 'package:password_manager/pages/onboarding.dart';
import 'package:password_manager/pages/splash.dart';
import 'package:password_manager/providers/current_user_provider.dart';
import 'package:password_manager/widgets/my_text.dart';

class PasswordManager extends ConsumerWidget {
  const PasswordManager({super.key});

  @override
  Widget build(context, ref) {
    // StreamBuilder to check Authentication State
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If any error occurred while checking the auth state
        if (snapshot.hasError) {
          return Center(
            child: MyText(
              text: "Some Error Occurred..\nPlease try again\nFirst",
              fontSize: 20,
              color: Theme.of(context).highlightColor,
              fontWeight: FontWeight.w500,
            ),
          );
        }

        // Showing SplashScreen while loading the app
        if (snapshot.connectionState == ConnectionState.waiting) {
          Future.delayed(Duration(seconds: 2));
          return const SplashScreen();
        }

        // If the user is already logged in
        if (snapshot.hasData) {
          final uid = snapshot.data!.uid;

          // FutureBuilder for fetching the user data from Firebase Firestore and storing it in currentUserProvider
          return FutureBuilder(
            // fetch user data and store in provider
            future: () async {
              final userSnapshot = await FirebaseFirestore.instance
                  .collection("User")
                  .doc(uid)
                  .get();
              final String email = userSnapshot["email"];
              final String name = userSnapshot["name"];
              final String password = userSnapshot["password"];
              final String userProfile= userSnapshot["profile_pic"];
              ref.read(currentUserProvider.notifier).updateData(
                    email,
                    name,
                    uid,
                    password,
                    userProfile,
                  );
              return userSnapshot;
            }(),
            builder: (context, snapshot) {
              // if any error occurred during fetching user data from firebase firestore
              if (snapshot.hasError) {
                // FirebaseAuth.instance.signOut();
                return Center(
                  child: MyText(
                    text: "Some Error Occurred..\nPlease try again\nSecond",
                    fontSize: 20,
                    color: Theme.of(context).highlightColor,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }

              // after successfully fetching the data go to HomePage
              if (snapshot.hasData) {
                return const HomePage();
              } 
              
              // exceptional case
              else {
                return const SplashScreen();
              }
            },
          );
        } 
        
        // If the user is not logged in
        else {
          return const OnboardingPage();
        }
      },
    );
  }
}
