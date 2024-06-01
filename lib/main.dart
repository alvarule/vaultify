// Import necessary packages
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_core/firebase_core.dart'; 
import 'firebase_options.dart'; 

import 'package:password_manager/utils/colors.dart'; 

import 'package:password_manager/password_manager.dart';

void main() async {
  // Ensure Flutter is properly initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase 
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Lock app orientation to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Run the app using ProviderScope for state management
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Build the root widget of your application
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Manager', 
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        // Customize the app's visual theme
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: primary, // Color of the text cursor during selection
          selectionColor: primaryOpacity50, // Color of the text selection highlight
          selectionHandleColor: primary, // Color of the text selection handles
        ),
      ),
      home: const PasswordManager(), // Set the PasswordManager widget as the initial screen
    );
  }
}
