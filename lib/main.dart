import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:meet_in_ground/Screens/onboarding/splashScreen.dart';
import 'package:meet_in_ground/constant/themes_service.dart';
import 'package:meet_in_ground/util/api/firebase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyCHm5EHrvpNixvs62Hs2hUndezVfBrQs8U",
      appId: "1:599300384798:android:af2f7b71e66b3abfed260f",
      messagingSenderId: "599300384798",
      projectId: "meetinground-464c9",
      storageBucket: "meetinground-464c9.appspot.com",
      measurementId: "G-BFZ54J6G31",
      authDomain: "meetinground-464c9.firebaseapp.com",
    ),
  );

  await FirebaseApi().initNotifications();

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

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
