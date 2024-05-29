import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:meet_in_ground/Screens/onboarding/splashScreen.dart';
import 'package:meet_in_ground/constant/themes_service.dart';
import 'package:meet_in_ground/util/api/firebase_service.dart'; // Adjust import path as needed

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyCHm5EHrvpNixvs62Hs2hUndezVfBrQs8U",
      appId: "1:599300384798:android:af2f7b71e66b3abfed260f",
      messagingSenderId: "599300384798",
      projectId: "meetinground-464c9",
    ),
  );

  // Initialize Firebase notifications
  await FirebaseApi().initNotifications();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        primaryColor: ThemeService.primary,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      color: Colors.transparent,
      home: SplashScreen(),
    );
  }
}
