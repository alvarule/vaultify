// Account Settings Page

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:password_manager/pages/auth.dart';
import 'package:password_manager/providers/current_user_provider.dart';
import 'package:password_manager/utils/constants.dart';
import 'package:password_manager/utils/services.dart';
import 'package:password_manager/widgets/my_text.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // appbar
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        // Button -> Back
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_circle_left_rounded,
            size: 28,
            color: Theme.of(context).highlightColor,
          ),
        ),

        // Title
        title: MyText(
          text: "My Account",
          fontSize: 22,
          color: Theme.of(context).highlightColor,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),

      // body
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              // Account Details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    Hero(
                      tag: "account",
                      child: CircleAvatar(
                        radius: 36,
                        backgroundColor: Theme.of(context).cardColor,
                        backgroundImage: NetworkImage(
                          ref
                              .watch(
                                  currentUserProvider)[CurrentUser.userProfile]
                              .toString(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          text:
                              ref.watch(currentUserProvider)[CurrentUser.name]!,
                          fontSize: 30,
                          color: Theme.of(context).highlightColor,
                          fontWeight: FontWeight.w600,
                        ),
                        MyText(
                          text: ref
                              .watch(currentUserProvider)[CurrentUser.email]!,
                          fontSize: 16,
                          color: Theme.of(context).highlightColor,
                          // fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Button -> Change Master Password
              Container(
                width: double.infinity,
                height: 60,
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: TextButton(
                  onPressed: () async {
                    // get the uid, email and master password
                    final uid = ref.read(currentUserProvider)[CurrentUser.uid];
                    final email =
                        ref.read(currentUserProvider)[CurrentUser.email];
                    final masterPass =
                        ref.read(currentUserProvider)[CurrentUser.masterPass];
                    if (await changeMasterPass(
                        context, uid!, email!, masterPass!)) {
                      FirebaseAuth.instance.signOut();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AuthPage(isLogin: true),
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              "Password Changed Successfully! Please login again.."),
                        ),
                      );
                    }
                  },
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all<EdgeInsets>(
                      const EdgeInsets.symmetric(vertical: 12),
                    ),
                    backgroundColor: WidgetStateProperty.all<Color>(Theme.of(context).primaryColor),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    foregroundColor: WidgetStateProperty.all<Color>(Theme.of(context).primaryColor),
                  ),
                  child: MyText(
                    text: "Change Master Password",
                    fontSize: 20,
                    color: Theme.of(context).focusColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
