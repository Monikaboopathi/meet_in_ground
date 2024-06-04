import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:meet_in_ground/Screens/onboarding/splashScreen.dart';
import 'package:meet_in_ground/constant/themes_service.dart';
import 'package:meet_in_ground/util/api/firebase_service.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  String API_KEY = dotenv.get("API_KEY", fallback: null);
  String API_ID = dotenv.get("API_ID", fallback: null);
  String SENDER_ID = dotenv.get("SENDER_ID", fallback: null);
  String PROJECT_ID = dotenv.get("PROJECT_ID", fallback: null);
  String STORAGE_BUCKET = dotenv.get("STORAGE_BUCKET", fallback: null);
  String MEASUREMENT_ID = dotenv.get("MEASUREMENT_ID", fallback: null);
  String AUTH_DOMAIN = dotenv.get("AUTH_DOMAIN", fallback: null);

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: API_KEY,
      appId: API_ID,
      messagingSenderId: SENDER_ID,
      projectId: PROJECT_ID,
      storageBucket: STORAGE_BUCKET,
      measurementId: MEASUREMENT_ID,
      authDomain: AUTH_DOMAIN,
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
