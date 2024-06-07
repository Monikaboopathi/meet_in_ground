import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meet_in_ground/constant/themes_service.dart';
import 'package:http/http.dart' as http;
import 'package:meet_in_ground/util/Services/mobileNo_service.dart';
import 'package:meet_in_ground/widgets/BottomNavigationScreen.dart';
import 'package:meet_in_ground/widgets/Loader.dart';

class Feedbackpage extends StatefulWidget {
  @override
  _FeedbackpageState createState() => _FeedbackpageState();
}

class _FeedbackpageState extends State<Feedbackpage> {
  final TextEditingController _messageController = TextEditingController();
  String _messageError = '';
  // ignore: unused_field
  bool _isLoading = false;

  bool _handleValidation() {
    if (_messageController.text.trim().isEmpty) {
      setState(() {
        _messageError = 'Message cannot be empty';
      });
      return false;
    }
    setState(() {
      _messageError = '';
    });
    return true;
  }

  Future<void> _handleSubmit() async {
    String Base_url = dotenv.get("BASE_URL", fallback: null);
    if (_handleValidation()) {
      setState(() {
        _isLoading = true;
      });

      String message = _messageController.text;

      String? userMobileNumber = await MobileNo.getMobilenumber();
      print(userMobileNumber);
      final String apiUrl = "$Base_url/user/addFeedback/$userMobileNumber";
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "message": message,
        }),
      );
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      print(responseData);

      if (response.statusCode == 200) {
        _messageController.clear();
        Fluttertoast.showToast(
          msg: responseData['message'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        Fluttertoast.showToast(
          msg: responseData['error'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );

        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        notificationPredicate: (notification) => false,
        automaticallyImplyLeading: true,
        backgroundColor: ThemeService.background,
        title: Text(
          'Feedback',
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
      body: WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => BottomNavigationScreen(currentIndex: 4),
            ),
          );
          return false;
        },
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Have suggestions to say? Please share with us below..',
                      style: TextStyle(
                          fontSize: 18, color: ThemeService.textColor),
                    ),
                    SizedBox(height: 20.0),
                    Row(
                      children: [
                        Text(
                          'Message ',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: ThemeService.textColor),
                        ),
                        Text(
                          '*',
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 20,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    TextField(
                      controller: _messageController,
                      maxLines: 5,
                      style: TextStyle(color: ThemeService.textColor),
                      decoration: InputDecoration(
                        hintText: 'Type your message here',
                        hintStyle: TextStyle(color: ThemeService.textColor),
                        errorText:
                            _messageError.isNotEmpty ? _messageError : null,
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (text) {
                        setState(() {
                          _messageError = '';
                        });
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return Loader();
                        },
                      );
                      // Delay for 2 seconds to show the loader
                      await Future.delayed(Duration(seconds: 2));

                      // Dismiss the loader and return to the previous page
                      Navigator.pop(context);
                      _handleSubmit();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      backgroundColor: ThemeService.buttonBg,
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                    ),
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
