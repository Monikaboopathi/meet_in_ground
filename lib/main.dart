import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meet_in_ground/Screens/widgets/BottomNavigationScreen.dart';
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
        primaryColor: ThemeService.background,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ScreenUtilInit(
          designSize: Size(375, 812), child: const BottomNavigationScreen()),
    );
  }
}
