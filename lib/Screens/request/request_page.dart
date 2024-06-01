// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:meet_in_ground/constant/themes_service.dart';
import 'package:meet_in_ground/util/Services/mobileNo_service.dart';
import 'package:meet_in_ground/widgets/BottomNavigationScreen.dart';
import 'package:meet_in_ground/widgets/NoDataFoundWidget.dart';

class RequestsScreen extends StatefulWidget {
  @override
  _RequestsScreenState createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  List<dynamic> requests = [];
  String matchDate = '';
  String userPhone = '';
  String userName = '';
  String userProfile = '';

  @override
  void initState() {
    super.initState();
    fetchData();
    getUserPhone();
  }

  fetchData() async {
    final url = 'https://bet-x-new.onrender.com/post/viewMyPostRequests/665acbb43649013badc71eba';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          requests = data['data'];
          matchDate = data['matchDate'];
        });
      } else {
        print('Failed to load requests');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  getUserPhone() async {
    final userPhone = await MobileNo.getMobilenumber();
    setState(() {
      this.userPhone = userPhone!;
    });
  }

  handleAccept(String userId) async {
    final url = 'https://bet-x-new.onrender.com/post/updateMyPostRequest/665acbb43649013badc71eba/$userId';
    try {
      final response = await http.patch(
        Uri.parse(url),
        body: jsonEncode({'status': 'Requested'}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          fetchData(); // Refetch the data after updating the status
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request accepted')));
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error['error'])));
      }
    } catch (error) {
      print(error);
    }
  }

  handleRequest(String userId) async {
    final url = 'https://bet-x-new.onrender.com/post/updateMyPostRequest/665acbb43649013badc71eba/$userId';
    try {
      final response = await http.patch(
        Uri.parse(url),
        body: jsonEncode({'status': 'Accepted'}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          fetchData(); // Refetch the data after updating the status
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request accepted')));
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error['error'])));
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: ThemeService.background,
        title: Text(
          'Requests',
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
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(8.0,8,8,15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Request: ${requests.length}',
                    style: TextStyle(color: ThemeService.textColor),
                  ),
                  Text(
                    'Match Date: $matchDate',
                    style: TextStyle(color: ThemeService.textColor),
                  ),
                ],
              ),
            ),
            Expanded(
              child: requests.isEmpty
                  ? NoDataFoundWidget()
                  : ListView.builder(
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        final item = requests[index];
                        return Container(
                          padding: EdgeInsets.all(8.0),
                          color: ThemeService.primary,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: item['profileImg'] != null
                                        ? NetworkImage(item['profileImg'])
                                        : AssetImage("assets/images/empty-img.jpg") as ImageProvider,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    item['userName'],
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                            item['status'] != 'Requested'
                                                ? handleAccept(item['_id'])
                                                : handleRequest(item['_id']);
                                          },
                                          child: Text(
                                            item['status'] != 'Requested' ? 'Accept' : 'Accepted',
                                          ),
                                        ),
                                  SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Handle navigation to chat screen
                                    },
                                    child: Text('Message'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
