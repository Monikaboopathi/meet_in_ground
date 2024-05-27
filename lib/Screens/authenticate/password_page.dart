import 'package:flutter/material.dart';
import 'package:meet_in_ground/Screens/authenticate/favourite_page.dart';
import 'package:meet_in_ground/Screens/widgets/BottomNavigationScreen.dart';
import 'package:meet_in_ground/constant/themes_service.dart';

class PasswordPage extends StatefulWidget {
  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController passwordController = TextEditingController();

  bool _isPasswordVisible = false;

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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          BottomNavigationScreen()),
                                );
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
                      const SizedBox(height: 6),
                      Center(
                        child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FavouritePage()),
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
