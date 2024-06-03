// ignore_for_file: camel_case_types, prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:meet_in_ground/Models/Post.dart';
import 'package:meet_in_ground/Screens/chat/ChatScreen.dart';
import 'package:meet_in_ground/widgets/OutlinedText_widget.dart';
import 'package:meet_in_ground/widgets/ShareMethods.dart';
import 'package:meet_in_ground/constant/themes_service.dart';

class Post_Widget extends StatefulWidget {
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
  final bool isShowMore;
  final Function(String) onToggleShowMore;
  final bool isFavorite;
  final VoidCallback onDeleteFav;
  final VoidCallback onFavoriteToggle;
  final bool isRequest;
  final VoidCallback onDeleteRequest;
  final VoidCallback onRequestToggle;
  final currentMobileNumber;
  final showLMSSection;
  final result;
  final showStatus;
  final showRequests;
  final onEditPost;
  final onDeletePost;
  const Post_Widget(
      {required this.id,
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
      required this.isShowMore,
      required this.onToggleShowMore,
      required this.isFavorite,
      required this.onDeleteFav,
      required this.onFavoriteToggle,
      required this.isRequest,
      required this.onDeleteRequest,
      required this.onRequestToggle,
      this.currentMobileNumber,
      this.showLMSSection,
      this.result,
      this.showStatus,
      this.showRequests,
      this.onEditPost,
      this.onDeletePost})
      : super(key: key);

  @override
  _Post_WidgetState createState() => _Post_WidgetState();
}

class _Post_WidgetState extends State<Post_Widget> {
  bool isAnimating = false;
  bool showEditDeleteIcons = false;
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
              backgroundImage: NetworkImage(widget.postOwnerImage),
              foregroundColor: Colors.amber,
            ),
            title: Row(
              children: [
                Text(
                  widget.userName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ThemeService.textColor,
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                if (widget.showRequests == true)
                  GestureDetector(
                    onTap: null,
                    child: Container(
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
                            widget.comments.toString(),
                            style: TextStyle(
                                fontSize: 10.0,
                                color: ThemeService.primary,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          GestureDetector(
                            onTap: () => widget.onRequestToggle(),
                            child: Text(
                              widget.comments > 1 ? "Requests" : "Request",
                              style: TextStyle(
                                  fontSize: 10.0,
                                  color: ThemeService.textColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (widget.phoneNumber != widget.currentMobileNumber)
                  GestureDetector(
                    onTap: !widget.isRequest
                        ? widget.onRequestToggle
                        : widget.onDeleteRequest,
                    child: Container(
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
                            widget.isRequest ? "Requested" : "Request",
                            style: TextStyle(
                                fontSize: 10.0, color: ThemeService.textColor),
                          ),
                        ],
                      ),
                    ),
                  )
              ],
            ),
            subtitle: Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: ThemeService.third,
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.placeOfMatch,
                    style: TextStyle(
                        color: ThemeService.third,
                        fontSize: 10,
                        fontWeight: FontWeight.w800),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onDoubleTap: () {
              if (widget.showLMSSection != false) {
                print("on double tap");
                print(widget.currentMobileNumber);
                setState(() {
                  if (widget.phoneNumber != widget.currentMobileNumber)
                    isAnimating = true;
                });
                if (widget.phoneNumber != widget.currentMobileNumber)
                  !widget.isFavorite
                      ? widget.onFavoriteToggle()
                      : widget.onDeleteFav();
              }
            },
            onLongPress: () {
              if (widget.showRequests == true) {
                setState(() {
                  showEditDeleteIcons = true;
                });
              }
            },
            onTap: () {
              if (widget.showRequests == true) {
                setState(() {
                  showEditDeleteIcons = false;
                });
              }
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 300.0,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(widget.image),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                if (widget.showStatus == true)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        color: Colors.black54,
                        padding: EdgeInsets.all(8),
                        child: Text(
                          widget.result ?? "----",
                          style: TextStyle(
                            color: ThemeService.third,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (widget.showStatus == true)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        color: Colors.black54,
                        padding: EdgeInsets.all(8),
                        child: Text(
                          widget.status,
                          style: TextStyle(
                            color: ThemeService.third,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (widget.phoneNumber != widget.currentMobileNumber)
                  AnimatedOpacity(
                    duration: Duration(milliseconds: 200),
                    opacity: isAnimating ? 1 : 0,
                    child: Icon(
                      Icons.favorite,
                      size: 100,
                      color: !widget.isFavorite ? Colors.red : Colors.white,
                    ),
                    onEnd: () {
                      setState(() {
                        isAnimating = false;
                      });
                    },
                  ),
                if (showEditDeleteIcons)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black54,
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: IconButton(
                                icon: Icon(Icons.edit, color: Colors.white),
                                onPressed: () {
                                  widget.onEditPost();
                                  setState(() {
                                    showEditDeleteIcons = false;
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 20),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.red.shade400,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: IconButton(
                                icon: Icon(Icons.delete, color: Colors.white),
                                onPressed: () {
                                  widget.onDeletePost();
                                  setState(() {
                                    showEditDeleteIcons = false;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedText_widget(
                    iconData: Icons.emoji_events, text: '${widget.betAmount}'),
                OutlinedText_widget(
                    iconData: Icons.sports_esports, text: '${widget.sport}'),
                OutlinedText_widget(
                    iconData: Icons.calendar_today,
                    text: "${widget.matchDate.toString().split(' ')[0]}")
              ],
            ),
          ),
          SizedBox(height: 8.0),
          if (widget.showLMSSection != false)
            Row(
              children: [
                if (widget.phoneNumber != widget.currentMobileNumber)
                  IconButton(
                    icon: Icon(
                      widget.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: widget.isFavorite
                          ? Colors.red
                          : ThemeService.textColor,
                    ),
                    onPressed: !widget.isFavorite
                        ? widget.onFavoriteToggle
                        : widget.onDeleteFav,
                  ),
                if (widget.phoneNumber != widget.currentMobileNumber)
                  IconButton(
                    icon: Icon(Icons.comment, color: ThemeService.textColor),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            recieverName: widget.userName,
                            recieverImage: widget.postOwnerImage,
                            receiverId: widget.phoneNumber,
                          ),
                        ),
                      );
                    },
                  ),
                IconButton(
                  icon: Icon(Icons.share, color: ThemeService.textColor),
                  onPressed: () {
                    sharePost(Post(
                      id: widget.id,
                      image: widget.image,
                      userName: widget.userName,
                      phoneNumber: widget.phoneNumber,
                      sport: widget.sport,
                      matchDetails: widget.matchDetails,
                      matchDate: widget.matchDate,
                      betAmount: widget.betAmount,
                      placeOfMatch: widget.placeOfMatch,
                      status: widget.status,
                      postOwnerImage: widget.postOwnerImage,
                      likes: widget.likes,
                      comments: widget.comments,
                      favorites: [],
                      requests: [],
                    ));
                  },
                ),
              ],
            ),
          if (widget.phoneNumber != widget.currentMobileNumber)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                '${widget.likes} like${widget.likes > 1 ? "s" : ""}',
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
              widget.isShowMore
                  ? '${widget.matchDetails}'
                  : widget.matchDetails.length > 80
                      ? '${widget.matchDetails.substring(0, 80)}... '
                      : '${widget.matchDetails}',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          SizedBox(height: 8.0),
          widget.matchDetails.length > 80
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: GestureDetector(
                    onTap: () => widget.onToggleShowMore(widget.id),
                    child: Text(
                      widget.isShowMore ? 'Show less' : 'Show more',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                )
              : Container(),
          SizedBox(height: 8.0),
          Divider(
            color: ThemeService.textColor.withOpacity(0.3),
            height: 1,
          ),
          SizedBox(height: 8.0),
        ],
      ),
    );
  }
}
