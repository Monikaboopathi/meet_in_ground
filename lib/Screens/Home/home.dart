// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors, sized_box_for_whitespace

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:meet_in_ground/Screens/widgets/Loader.dart';
import 'package:meet_in_ground/Screens/widgets/NoDataFoundWidget.dart';
import 'package:meet_in_ground/Screens/widgets/post_widget.dart';
import 'package:meet_in_ground/constant/themes_service.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Post>> futurePosts;

  @override
  void initState() {
    super.initState();
    futurePosts = fetchPosts();
  }

  Future<List<Post>> fetchPosts() async {
    final response = await http.get(
        Uri.parse('https://bet-x-new.onrender.com/post/viewPostsDashboard'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)['data'];
      return jsonResponse.map((post) => Post.fromJson(post)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

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
        bottom: PreferredSize(
          preferredSize: Size(double.infinity, 35),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Container(
                    height: 40,
                    child: TextField(
                      style: TextStyle(color: ThemeService.textColor),
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: TextStyle(color: ThemeService.textColor),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.search),
                          color: ThemeService.textColor,
                          onPressed: () {
                            // Handle search functionality
                          },
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: ThemeService.primary),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.filter_alt),
                color: ThemeService.textColor,
                onPressed: () {
                  // Handle filter functionality
                },
              ),
              IconButton(
                icon: Icon(Icons.sort),
                color: ThemeService.textColor,
                onPressed: () {
                  // Handle sort functionality
                },
              ),
            ],
          ),
        ),
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
      body: FutureBuilder<List<Post>>(
        future: futurePosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Loader());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: NoDataFoundWidget(),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Post post = snapshot.data![index];
                return Post_Widget(
                  userName: post.userName,
                  placeOfMatch: post.placeOfMatch,
                  likes: post.likes,
                  comments: post.comments,
                  betAmount: post.betAmount,
                  id: post.id,
                  image: post.image,
                  postOwnerImage: post.postOwnerImage,
                  matchDate: post.matchDate,
                  matchDetails: post.matchDetails,
                  phoneNumber: post.phoneNumber,
                  sport: post.sport,
                  status: post.status,
                );
              },
            );
          }
        },
      ),
    );
  }
}

// models/post.dart
class Post {
  final String id;
  final String image;
  final String userName;
  final String phoneNumber;
  final String sport;
  final String matchDetails;
  final String matchDate;
  final int betAmount;
  final String placeOfMatch;
  final String status;
  final String postOwnerImage;
  final int likes;
  final int comments;
  final List<dynamic> favorites;
  final List<dynamic> requests;

  Post({
    required this.id,
    required this.image,
    required this.userName,
    required this.phoneNumber,
    required this.sport,
    required this.matchDetails,
    required this.matchDate,
    required this.betAmount,
    required this.placeOfMatch,
    required this.status,
    required this.postOwnerImage,
    required this.likes,
    required this.comments,
    required this.favorites,
    required this.requests,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id'],
      image: json['image'],
      userName: json['userName'],
      phoneNumber: json['phoneNumber'],
      sport: json['sport'],
      matchDetails: json['matchDetails'],
      matchDate: json['matchDate'],
      betAmount: json['betAmount'],
      placeOfMatch: json['placeOfMatch'],
      status: json['status'],
      postOwnerImage: json['postOwnerImage'],
      likes: json['favorites'].length,
      comments: json['requests'].length,
      favorites: json['favorites'],
      requests: json['requests'],
    );
  }
}
