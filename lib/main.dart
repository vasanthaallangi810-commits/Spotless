import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

// 1. Add these two Firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Your existing SQLite web setup
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  // 2. Add the Firebase initialization
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SpotlessApp());
}

class SpotlessApp extends StatelessWidget {
  const SpotlessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Spotless',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        scaffoldBackgroundColor: const Color(0xFFF7F4D5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A3323),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}