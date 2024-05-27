import 'package:flutter/material.dart';
import 'package:meet_in_ground/Screens/widgets/post_widget.dart';
import 'package:meet_in_ground/constant/themes_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeService.background,
        title: Text(
          'Meet In Ground',
          style: TextStyle(
            color: ThemeService.textColor,
            fontFamily: 'Billabong',
            fontSize: 25,
          ),
        ),
        centerTitle: true,
        // leading: IconButton(
        //   icon: Icon(Icons.camera_alt),
        //   color: ThemeService.textColor,
        //   onPressed: () {},
        // ),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.send),
        //     color: ThemeService.textColor,
        //     onPressed: () {},
        //   ),
        // ],
      ),
      body: ListView.builder(
        itemCount: 10, // Number of posts to display
        itemBuilder: (context, index) {
          return Post_Widget(
            username: 'user$index', // Fake username
            location:
                'Kadirimangalam, Tirupathur, Tamil Nadu 635653 $index', // Fake location
            likes: index * 10, // Fake number of likes
            comments: index * 5, // Fake number of comments
          );
        },
      ),
    );
  }
}
