// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meet_in_ground/constant/themes_service.dart';
import 'package:meet_in_ground/util/Services/mobileNo_service.dart';
import 'package:meet_in_ground/widgets/BottomNavigationScreen.dart';
import 'package:meet_in_ground/widgets/NoDataFoundWidget.dart';

class Notificationspage extends StatefulWidget {
  @override
  _NotificationspageState createState() => _NotificationspageState();
}

class _NotificationspageState extends State<Notificationspage> {
  List<dynamic> notificationData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  fetchData() async {
    try {
      String? userMobileNumber = await MobileNo.getMobilenumber();
      print('User Mobile Number: $userMobileNumber');

      final response = await http.get(
        Uri.parse(
            'https://bet-x-new.onrender.com/user/viewNotifications/$userMobileNumber'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('API Response Data: $data');

        if (data != null && data['data'] != null) {
          setState(() {
            notificationData = data['data'];
            isLoading = false;
          });
        } else {
          print('No notifications found in response.');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print('Failed to load notifications: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatTimestamp(DateTime timestamp) {
    if (timestamp == null) return ""; // Handling null or undefined timestamp
    if (isToday(timestamp)) {
      Duration difference = DateTime.now().difference(timestamp);
      String timeDifference = formatDuration(difference);
      return "${timeDifference[0].toUpperCase()}${timeDifference.substring(1)} ago";
    } else {
      return DateFormat('hh:mm a').format(timestamp);
    }
  }

  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool isYesterday(DateTime date) {
    final now = DateTime.now();
    final yesterday = now.subtract(Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  String formatDuration(Duration duration) {
    if (duration.inDays > 0) return "${duration.inDays} days";
    if (duration.inHours > 0) return "${duration.inHours} hours";
    if (duration.inMinutes > 0) return "${duration.inMinutes} minutes";
    return "Just now";
  }

  String getHeaderDate(DateTime date) {
    if (date == null) return ""; // Handling null or undefined date
    if (isToday(date)) {
      return "Today";
    } else if (isYesterday(date)) {
      return "Yesterday";
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: ThemeService.background,
        title: Text(
          'Notification',
          style: TextStyle(
            color: ThemeService.textColor,
            fontFamily: 'Billabong',
            fontSize: 25,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ThemeService.textColor, size: 35),
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => BottomNavigationScreen(currentIndex: 4),
            ),
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: ThemeService.background,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : notificationData.isNotEmpty
              ? ListView.builder(
                  itemCount: notificationData.length,
                  itemBuilder: (context, index) {
                    var notification = notificationData[index];
                    DateTime? date = notification['createdAt'] != null
                        ? DateTime.parse(notification['createdAt'])
                        : null;
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 2, 10, 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left:12.0),
                            child: Text(
                              getHeaderDate(date!),
                              style: TextStyle(
                                color: ThemeService.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Card(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: ThemeService.primary,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    child: Image.network(
                                      notification['image'] ?? '',
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          notification['title'],
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: ThemeService.textColor
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(notification['body'],style:TextStyle(color: ThemeService.textColor)),
                                        SizedBox(height: 5),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Text(
                                            formatTimestamp(date),
                                            style: TextStyle(
                                              color: ThemeService.buttonBg,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
              : NoDataFoundWidget(),
    );
  }
}
