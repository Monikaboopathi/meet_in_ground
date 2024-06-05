import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:meet_in_ground/util/Services/PreferencesService.dart';

import '../authenticate/login_page.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;

  void handleDone() async {
    await PreferencesService.saveValue("onboard", "true");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }

  final List<Color> pageColors = [
    Color(0xFF003B71),
    Color(0xFF008905),
    Color(0xFF320071),
  ];

  Widget buildImage(String assetName) {
    return Align(
      child: Image.asset(
        assetName,
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.6,
        fit: BoxFit.contain,
      ),
      alignment: Alignment.center,
    );
  }

  Widget buildIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildIcon(Icons.group, 0),
        SizedBox(width: 10),
        buildIcon(Icons.message, 1),
        SizedBox(width: 10),
        buildIcon(Icons.sports_soccer, 2),
      ],
    );
  }

  Widget buildIcon(IconData icon, int index) {
    bool isSelected = _currentPage == index;
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.5) : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color:
              isSelected ? Colors.white.withOpacity(0.9) : Colors.transparent,
          width: 2,
        ),
      ),
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }

  PageViewModel buildPageViewModel({
    required Color color,
    required String image,
    required Widget body,
  }) {
    return PageViewModel(
      decoration: PageDecoration(
        pageColor: color,
        bodyAlignment: Alignment.center,
      ),
      title: '',
      bodyWidget: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          buildImage(image),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          body,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: IntroductionScreen(
        pages: [
          buildPageViewModel(
            color: Color(0xFF003B71),
            image: 'assets/onboarding1.png',
            body: Text(
              'Connect with sports enthusiasts across India for Friendly betting matches!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.width * 0.05,
              ),
            ),
          ),
          buildPageViewModel(
            color: Color(0xFF008905),
            image: 'assets/onboarding2.png',
            body: Text(
              'Create a post to challenge others to a match and place a bet as a Reward..!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.width * 0.05,
              ),
            ),
          ),
          buildPageViewModel(
            color: Color(0xFF320071),
            image: 'assets/onboarding3.png',
            body: Text(
              'It’s time to kick-off your sports betting experience. Let’s dive into the Match !!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.width * 0.05,
              ),
            ),
          ),
        ],
        onDone: handleDone,
        onSkip: handleDone,
        onChange: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        showSkipButton: true,
        skip: const Text('Skip',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
        next: const Icon(
          Icons.arrow_forward,
          size: 30,
          color: Colors.white,
        ),
        done: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Get Started',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
        globalBackgroundColor: pageColors[_currentPage],
        globalHeader: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05),
          child: buildIcons(),
        ),
        dotsDecorator: DotsDecorator(
          spacing: EdgeInsets.only(top: 10, right: 5, left: 5),
          activeColor: Colors.white,
          color: Colors.white.withOpacity(0.3),
          size: Size(15.0, 15.0),
          activeSize: Size(25.0, 10.0),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
        ),
      ),
    );
  }
}
