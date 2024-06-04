// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:meet_in_ground/Screens/chat/ChatScreen.dart';
import 'dart:convert';
import 'package:meet_in_ground/constant/themes_service.dart';
import 'package:meet_in_ground/util/Services/mobileNo_service.dart';
import 'package:meet_in_ground/widgets/Loader.dart';
import 'package:meet_in_ground/widgets/NoDataFoundWidget.dart';

class RequestsScreen extends StatefulWidget {
  String postId;

  RequestsScreen({
    required this.postId,
    Key? key,
  }) : super(key: key);
  @override
  _RequestsScreenState createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  List<dynamic> requests = [];
  String matchDate = '';
  String userPhone = '';
  String userName = '';
  String userProfile = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchData();
    getUserPhone();
  }

  fetchData() async {
    String Base_url = dotenv.get("BASE_URL", fallback: null);
    setState(() {
      isLoading = true;
    });
    final url = '$Base_url/post/viewMyPostRequests/${widget.postId}';
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
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  getUserPhone() async {
    final userPhone = await MobileNo.getMobilenumber();
    setState(() {
      this.userPhone = userPhone!;
    });
  }

  handleAccept(String userId) async {
    String Base_url = dotenv.get("BASE_URL", fallback: null);
    final url = '$Base_url/post/updateMyPostRequest/${widget.postId}/$userId';
    try {
      final response = await http.patch(
        Uri.parse(url),
        body: jsonEncode({'status': 'Requested'}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        fetchData();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Request accepted')));
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error['error'])));
      }
    } catch (error) {
      print(error);
    }
  }

  handleRequest(String userId) async {
    String Base_url = dotenv.get("BASE_URL", fallback: null);
    final url = '$Base_url/post/updateMyPostRequest/${widget.postId}/$userId';
    try {
      final response = await http.patch(
        Uri.parse(url),
        body: jsonEncode({'status': 'Accepted'}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        fetchData();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Request Removed')));
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error['error'])));
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
            icon:
                Icon(Icons.arrow_back, color: ThemeService.textColor, size: 35),
            onPressed: () => Navigator.pop(context)),
        centerTitle: true,
      ),
      backgroundColor: ThemeService.background,
      body: Container(
        child: Column(
          children: [
            requests.length == 0
                ? Container()
                : Padding(
                    padding: EdgeInsets.fromLTRB(8.0, 8, 8, 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Total Request: ',
                              style: TextStyle(
                                color: ThemeService.textColor,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${requests.length}',
                              style: TextStyle(
                                  color: ThemeService.third,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Match Date: ',
                              style: TextStyle(
                                color: ThemeService.textColor,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${matchDate}',
                              style: TextStyle(
                                  color: ThemeService.third,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
            Expanded(
              child: isLoading
                  ? Loader()
                  : requests.isEmpty
                      ? NoDataFoundWidget()
                      : ListView.builder(
                          itemCount: requests.length,
                          itemBuilder: (context, index) {
                            final item = requests[index];
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 8),
                                  child: Container(
                                    padding: EdgeInsets.all(10.0),
                                    decoration: BoxDecoration(
                                      color: ThemeService.primary,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundImage: item[
                                                          'profileImg'] !=
                                                      null
                                                  ? NetworkImage(
                                                      item['profileImg'])
                                                  : AssetImage(
                                                          "assets/images/empty-img.jpg")
                                                      as ImageProvider,
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              item['userName'],
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            ElevatedButton(
                                              style: ButtonStyle(
                                                padding: MaterialStateProperty
                                                    .all<EdgeInsets>(
                                                        EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 2)),
                                                minimumSize: MaterialStateProperty
                                                    .all<Size>(Size(50,
                                                        30)), // Set the size as needed
                                                shape:
                                                    MaterialStateProperty.all<
                                                        RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8), // Set border radius if you want rounded corners
                                                  ),
                                                ),
                                              ),
                                              onPressed: () {
                                                item['status'] != 'Requested'
                                                    ? handleAccept(item['_id'])
                                                    : handleRequest(
                                                        item['_id']);
                                              },
                                              child: Text(
                                                item['status'] != 'Requested'
                                                    ? 'Accept'
                                                    : 'Accepted',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        ThemeService.primary),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            ElevatedButton(
                                              style: ButtonStyle(
                                                padding: MaterialStateProperty
                                                    .all<EdgeInsets>(
                                                        EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 2)),
                                                minimumSize: MaterialStateProperty
                                                    .all<Size>(Size(50,
                                                        30)), // Set the size as needed
                                                shape:
                                                    MaterialStateProperty.all<
                                                        RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8), // Set border radius if you want rounded corners
                                                  ),
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pushReplacement(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ChatScreen(
                                                      recieverName:
                                                          item['userName'],
                                                      recieverImage:
                                                          item['profileImg'],
                                                      receiverId:
                                                          item['phoneNumber'],
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                'Message',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        ThemeService.primary),
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
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
