import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meet_in_ground/Screens/authenticate/favourite_page.dart';
import 'package:meet_in_ground/util/Services/Auth_service.dart';
import 'package:meet_in_ground/util/Services/PreferencesService.dart';
import 'package:meet_in_ground/util/Services/image_service.dart';
import 'package:meet_in_ground/util/Services/mobileNo_service.dart';
import 'package:meet_in_ground/util/Services/userName_service.dart';
import 'package:meet_in_ground/util/api/Firebase_service.dart';
import 'package:meet_in_ground/widgets/BottomNavigationScreen.dart';
import 'package:meet_in_ground/constant/themes_service.dart';
import 'package:http/http.dart' as http;
import 'package:meet_in_ground/widgets/Loader.dart';
import 'package:meet_in_ground/util/Services/refferral_service.dart';

String fcmToken = "";
String referralId = "";

class PasswordPage extends StatefulWidget {
  const PasswordPage({
    Key? key,
    required this.mobile,
  }) : super(key: key);

  final String mobile;

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    getToken();
  }

  void getToken() async {
    // Initialize Firebase
    await Firebase.initializeApp();

    // Get FCM token
    setState(() async {
      fcmToken = await FirebaseApi().getFcmToken();
      referralId = (await RefferalService.getRefferal()) ?? "";
    });

    // Use fcmToken here
    print('FCM Token: $fcmToken');
  }

  Future<void> verifyPassword(
      String phoneNumber, String password, BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    print(referralId);

    final String apiUrl = 'https://bet-x-new.onrender.com/user/verifyPassword';

    // Create a map containing the request body parameters
    final Map<String, dynamic> requestBody = {
      'phoneNumber': phoneNumber,
      'password': password,
      'fcmToken': fcmToken
    };
    print(fcmToken);

    try {
      // Make the POST request to the API endpoint
      final http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      // Parse the response body
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => BottomNavigationScreen(
              currentIndex: 0,
            ),
          ),
          (route) => false,
        );
        Fluttertoast.showToast(
          msg: 'SUCCESS',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        // String email = responseData['phoneNumber'];
        await MobileNo.saveMobilenumber(phoneNumber);
        print(phoneNumber);
        print(responseData['referralId']);
        print(responseData['userName']);
        print(responseData['profileImg']);
        await RefferalService.clearRefferal();
        await AuthService.saveToken("token");
        await PreferencesService.saveValue('login', "true");
        await RefferalService.saveRefferal("${responseData['referralId']}");
        await UsernameService.saveUserName("${responseData['userName']}");
        await ImageService.saveImage("${responseData['profileImg']}");
      } else {
        Fluttertoast.showToast(
          msg: responseData['message'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        await MobileNo.clearMobilenumber();
      }
    } catch (exception) {
      print(exception);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 100, 8, 50),
                  child: Image.asset(
                    'assets/login.png',
                    width: MediaQuery.of(context).size.width,
                    height: 280,
                    fit: BoxFit.fill,
                  ),
                ),
                SizedBox(height: 50),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: [
                          Text(
                            'Enter your password here',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '*',
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 45,
                      ),
                      TextFormField(
                        obscureText:
                            !_isPasswordVisible, // This hides the entered text
                        controller:
                            passwordController, // Your controller for handling the input
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: ThemeService.primary),
                          ),
                          prefixIcon:
                              Icon(Icons.lock), // Icon for password input
                          hintText: 'Enter your Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),

                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Password';
                          } else {
                            // Implement additional password validation if needed
                            return null;
                          }
                        },
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Center(
                        child: Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                String mobileNO = widget.mobile;
                                String password =
                                    passwordController.text.trim();
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return Loader();
                                  },
                                );
                                await verifyPassword(
                                    mobileNO, password, context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              backgroundColor: ThemeService.buttonBg,
                            ),
                            child: const Text(
                              'Submit',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: TextButton(
                            onPressed: () async {
                              // Show loader
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return Loader();
                                },
                              );

                              await Future.delayed(Duration(seconds: 2));
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FavouritePage(
                                      mobile: widget.mobile, status: 200),
                                ),
                              );
                            },
                            child: Text(
                              'Forgot Password',
                              style: TextStyle(
                                  color: ThemeService.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline),
                              softWrap: true,
                            )),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
