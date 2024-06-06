import 'package:flutter/material.dart';
import 'package:meet_in_ground/Screens/authenticate/login_page.dart';
import 'package:meet_in_ground/Screens/authenticate/userdetails_page.dart';
import 'package:meet_in_ground/Screens/onboarding/Onboarding.dart';
import 'package:meet_in_ground/constant/themes_service.dart';
import 'package:meet_in_ground/util/Services/PreferencesService.dart';

import '../../util/Services/Auth_service.dart';
import '../../widgets/BottomNavigationScreen.dart';

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
      String? onboard = await PreferencesService.getValue('onboard');
      String? login = await PreferencesService.getValue('login');
      print(token);
      if (onboard == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OnboardingScreen(),
          ),
        );
      } else if (login == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else if (token == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => UserOnBoard(
              mobile: '',
              favhero: '',
              favcolor: '',
              password: '',
              confirmpassword: '',
            ),
          ),
        );
      } else if (token != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => BottomNavigationScreen(
              currentIndex: 0,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error during authentication check: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: ThemeService.primary,
        child: Image.asset(
          'assets/splash.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
