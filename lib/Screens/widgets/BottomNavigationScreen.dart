import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meet_in_ground/Screens/Favorites/Favorites.dart';
import 'package:meet_in_ground/Screens/Home/home.dart';
import 'package:meet_in_ground/Screens/Messages/Messages.dart';
import 'package:meet_in_ground/Screens/Posts/AddPosts.dart';
import 'package:meet_in_ground/Screens/Profile/Profile.dart';
import 'package:meet_in_ground/constant/themes_service.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({Key? key}) : super(key: key);

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

int _currentIndex = 0;

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  onPageChanged(int page) {
    setState(() {
      _currentIndex = page;
    });
  }

  navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: ThemeService.textColor,
          unselectedItemColor: Colors.grey,
          currentIndex: _currentIndex,
          onTap: navigationTapped,
          backgroundColor: ThemeService.background,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message_sharp),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_rounded),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: '',
            ),
          ],
        ),
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        children: [
          HomeScreen(),
          Messages(),
          Addposts(),
          Favorites(),
          Profile()
        ],
      ),
    );
  }
}
