import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meet_in_ground/Screens/authenticate/login_page.dart';
import 'package:meet_in_ground/Screens/util/Services/refferral_service.dart';
import 'package:meet_in_ground/constant/themes_service.dart';
import 'package:http/http.dart' as http;

import '../../util/Services/mobileNo_service.dart';
import 'userdetails_page.dart';

class SetPasswordPage extends StatefulWidget {
  final String mobile;
  final String color;
  final String hero;
  final int status;

  const SetPasswordPage({
    Key? key,
    required this.mobile,
    required this.color,
    required this.hero,
    required this.status,
  }) : super(key: key);

  @override
  State<SetPasswordPage> createState() => _SetPasswordPageState();
}

class _SetPasswordPageState extends State<SetPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool isLoading = false;

  void _submitpatchform() async {
    setState(() {
      isLoading = true;
    });

    String mobile = widget.mobile;
    String password = passwordController.text;
    String confirmPassword = confirmpasswordController.text;

    // Prepare data for API call
    Map<String, dynamic> requestData = {
      "phoneNumber": mobile,
      "newPassword": password,
      "confirmPassword": confirmPassword,
    };

    // API endpoint
    final String apiUrl = 'https://bet-x-new.onrender.com/user/resetPassword';

    try {
      // Make PATCH request
      final response = await http.patch(
        Uri.parse(apiUrl),
        body: jsonEncode(requestData),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      // Check response status
      if (response.statusCode == 200) {
        // Password reset successful
        Fluttertoast.showToast(
          msg: 'Login successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        await MobileNo.saveMobilenumber(mobile);
        await RefferalService.clearRefferal();
        await RefferalService.saveRefferal("${responseData['referralId']}");

        // Navigate to the home page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
        );
        // Handle navigation or any other action as needed
      } else {
        // Password reset failed
        Fluttertoast.showToast(
          msg: 'Login failed. Please try again later',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        // Handle error response as needed
      }
    } catch (exception) {
      // Exception occurred during API call
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
                SizedBox(height: 10),
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
                            'Password',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w800),
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
                        height: 20,
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
                          hintText: 'Enter Password',
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
                        validator: (password) {
                          if (password == null || password.isEmpty) {
                            return 'Please enter Password';
                          } else if (password.length < 8) {
                            return 'Password must be at least 8 characters long';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            'Confirm Password',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w800),
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
                        height: 20,
                      ),
                      TextFormField(
                        obscureText:
                            !_isConfirmPasswordVisible, // This hides the entered text
                        controller:
                            confirmpasswordController, // Your controller for handling the input
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: ThemeService.primary),
                          ),
                          prefixIcon:
                              Icon(Icons.lock), // Icon for password input
                          hintText: 'Enter Confirm Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (confirmPassword) {
                          if (confirmPassword == null ||
                              confirmPassword.isEmpty) {
                            return 'Please enter Confirm Password';
                          } else if (confirmPassword !=
                              passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
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
                                String mobile = widget.mobile;
                                String hero = widget.hero;
                                String color = widget.color;
                                String password = passwordController.text;
                                String confirmPassword =
                                    confirmpasswordController.text;
                                if (widget.status == 200) {
                                  _submitpatchform();
                                  ;
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => UserOnBoard(
                                            mobile: mobile,
                                            favhero: hero,
                                            favcolor: color,
                                            password: password,
                                            confirmpassword: confirmPassword)),
                                  );

                                  Fluttertoast.showToast(
                                    msg: 'Favourites  Addded Successfully',
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.TOP,
                                    timeInSecForIosWeb: 2,
                                    backgroundColor: Colors.green,
                                    textColor: Colors.white,
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              backgroundColor: ThemeService.primary,
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
