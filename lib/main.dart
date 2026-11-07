import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'data/app_data.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  await AppData.loadSavedReports();

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