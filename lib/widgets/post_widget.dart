// ignore_for_file: camel_case_types, prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:meet_in_ground/Models/Post.dart';
import 'package:meet_in_ground/widgets/OutlinedText_widget.dart';
import 'package:meet_in_ground/widgets/ShareMethods.dart';
import 'package:meet_in_ground/constant/themes_service.dart';

class Post_Widget extends StatelessWidget {
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

  const Post_Widget({
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
    Key? key,
    required createdAt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeService.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 20.0,
              backgroundImage: NetworkImage(postOwnerImage),
              foregroundColor: Colors.amber,
            ),

            title: Row(
              children: [
                Text(
                  userName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ThemeService.textColor,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: ThemeService.textColor,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 1, horizontal: 6),
                  child: Row(
                    children: [
                      Text(
                        "Request",
                        style: TextStyle(
                            fontSize: 10.0, color: ThemeService.textColor),
                      ),
                    ],
                  ),
                )
              ],
            ),
            subtitle: Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: Colors.grey,
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    placeOfMatch,
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            // trailing: Icon(Icons.more_horiz, color: ThemeService.textColor),
          ),
          Container(
            height: 300.0,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(image),
                fit: BoxFit.fill,
              ),
            ),
          ),
          SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedText_widget(
                    iconData: Icons.emoji_events, text: '$betAmount'),
                OutlinedText_widget(
                    iconData: Icons.sports_esports, text: '$sport'),
                OutlinedText_widget(
                    iconData: Icons.calendar_today, text: "$matchDate")
              ],
            ),
          ),
          SizedBox(height: 8.0),
          Row(
            children: [
              IconButton(
                icon:
                    Icon(Icons.favorite_border, color: ThemeService.textColor),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.comment, color: ThemeService.textColor),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.share, color: ThemeService.textColor),
                onPressed: () {
                  sharePost(Post(
                    id: id,
                    image: image,
                    userName: userName,
                    phoneNumber: phoneNumber,
                    sport: sport,
                    matchDetails: matchDetails,
                    matchDate: matchDate,
                    betAmount: betAmount,
                    placeOfMatch: placeOfMatch,
                    status: status,
                    postOwnerImage: postOwnerImage,
                    likes: likes,
                    comments: comments,
                    favorites: [],
                    requests: [],
                  ));
                },
              ),
              // Spacer(),
              // IconButton(
              //   icon:
              //       Icon(Icons.bookmark_border, color: ThemeService.textColor),
              //   onPressed: () {},
              // ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              '$likes likes',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ThemeService.textColor,
              ),
            ),
          ),
          SizedBox(height: 4.0),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              'Caption',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: ThemeService.textColor,
              ),
            ),
          ),
          SizedBox(height: 8.0),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              'View all $comments comments',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          SizedBox(height: 8.0),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12.0,
                  backgroundImage: AssetImage('assets/galleryImage.png'),
                ),
                SizedBox(width: 8.0),
                Text(
                  'comment',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: ThemeService.textColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.0),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              '5 hours ago',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          SizedBox(height: 16.0),
        ],
      ),
    );
  }
}
