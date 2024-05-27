import 'package:flutter/material.dart';
import 'package:meet_in_ground/Screens/onboarding/Onboarding.dart';

import '../util/Services/Auth_service.dart';
import '../widgets/BottomNavigationScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    checkAuthState();
  }

  Future<void> checkAuthState() async {
    try {
      await Future.delayed(Duration(seconds: 2));

      if (!mounted) return;

      String? token = await AuthService.getToken();
      print(token);
      if (token != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => BottomNavigationScreen(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OnboardingScreen(),
          ),
        );
        await AuthService.saveToken("token");
        print(token);
      }
    } catch (e) {
      print('Error during authentication check: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // ignore: sized_box_for_whitespace
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Image.asset(
            'assets/splash.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
