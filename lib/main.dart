// Import necessary packages
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

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
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home:
          const PasswordManager(), // Set the PasswordManager widget as the initial screen
    );
  }
}

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color.fromARGB(255, 242, 22, 73),
  primaryColorLight: const Color.fromARGB(119, 242, 22, 73),
  primaryColorDark: const Color.fromARGB(255, 154, 22, 52),
  highlightColor: const Color.fromARGB(255, 23, 31, 70),
  hintColor: const Color.fromARGB(255, 117, 119, 132),
  unselectedWidgetColor: Color.fromARGB(255, 211, 212, 218),
  scaffoldBackgroundColor: const Color.fromARGB(255, 240, 244, 247),
  cardColor: const Color.fromARGB(255, 255, 255, 255),
  focusColor: Colors.white,
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Color.fromARGB(255, 242, 22, 73),
    selectionColor: Color.fromARGB(119, 242, 22, 73),
    selectionHandleColor: Color.fromARGB(255, 242, 22, 73),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color.fromARGB(255, 242, 22, 73),
  primaryColorLight: const Color.fromARGB(119, 242, 22, 73),
  primaryColorDark: const Color.fromARGB(255, 154, 22, 52),
  highlightColor: const Color.fromARGB(255, 224, 229, 255),
  hintColor: const Color.fromARGB(255, 170, 173, 193),
  unselectedWidgetColor: Color.fromARGB(255, 143, 143, 144),
  scaffoldBackgroundColor: const Color.fromARGB(255, 0, 0, 0),
  cardColor: const Color.fromARGB(255, 34, 37, 49),
  focusColor: Colors.white,
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Color.fromARGB(255, 242, 22, 73),
    selectionColor: Color.fromARGB(119, 242, 22, 73),
    selectionHandleColor: Color.fromARGB(255, 242, 22, 73),
  ),
);
