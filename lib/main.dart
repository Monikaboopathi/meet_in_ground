// ignore_for_file: prefer_const_constructors, unused_import

import 'package:flutter/material.dart';
import 'package:meet_in_ground/widgets/BottomNavigationScreen.dart';
import 'Screens/onboarding/splashScreen.dart';

import 'package:meet_in_ground/constant/themes_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        primaryColor: ThemeService.primary,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BottomNavigationScreen(),
    );
  }
}
