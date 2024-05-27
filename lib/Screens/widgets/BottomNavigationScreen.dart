// ignore_for_file: prefer_const_constructors

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

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  late PageController pageController;
  int _currentIndex = 0;

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

  void onPageChanged(int page) {
    setState(() {
      _currentIndex = page;
    });
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        height: 60,
        child: BottomAppBar(
          color: ThemeService.background,
          shape: CircularNotchedRectangle(),
          child: Container(
            height: kBottomNavigationBarHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: _currentIndex == 0
                      ? Icon(
                          Icons.home,
                          color: ThemeService.textColor,
                        )
                      : Icon(Icons.home_outlined, color: Colors.grey),
                  onPressed: () => navigationTapped(0),
                ),
                IconButton(
                  icon: _currentIndex == 1
                      ? Icon(Icons.message_sharp, color: ThemeService.textColor)
                      : Icon(Icons.message_outlined, color: Colors.grey),
                  onPressed: () => navigationTapped(1),
                ),
                IconButton(
                  icon: _currentIndex == 2
                      ? Icon(Icons.add_circle_rounded,
                          color: ThemeService.textColor)
                      : Icon(Icons.add_circle_outline_rounded,
                          color: Colors.grey),
                  onPressed: () => navigationTapped(2),
                ),
                IconButton(
                  icon: _currentIndex == 3
                      ? Icon(Icons.favorite, color: ThemeService.textColor)
                      : Icon(Icons.favorite_border, color: Colors.grey),
                  onPressed: () => navigationTapped(3),
                ),
                IconButton(
                  icon: _currentIndex == 4
                      ? Icon(Icons.person, color: ThemeService.textColor)
                      : Icon(Icons.person_outline, color: Colors.grey),
                  onPressed: () => navigationTapped(4),
                ),
              ],
            ),
          ),
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
          Profile(),
        ],
      ),
    );
  }
}
