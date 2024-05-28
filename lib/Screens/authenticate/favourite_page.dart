import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meet_in_ground/constant/themes_service.dart';
import 'package:http/http.dart' as http;

import 'setPassword_page.dart';

class FavouritePage extends StatefulWidget {
  final String mobile;
  final int status;

  const FavouritePage({Key? key, required this.mobile, required this.status})
      : super(key: key);
  @override
  State<FavouritePage> createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController heroController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  bool isLoading = false;

  Future<void> submitUserData(
      String phoneNumber, String favoriteHero, String favoriteColor) async {
    setState(() {
      isLoading = true;
    });

    String apiUrl = 'https://bet-x-new.onrender.com/user/forgotPassword';
    print(phoneNumber);
    print(favoriteHero);
    print(favoriteColor);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'favoriteColor': favoriteColor,
          'favoriteHero': favoriteHero,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      print(responseData);

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: responseData['message'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        // Handle successful response here
        print('Data submitted successfully');
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SetPasswordPage(
                  mobile: phoneNumber,
                  hero: favoriteHero,
                  color: favoriteColor,
                  status: 200)),
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
        // Handle error response here
        print('Failed to submit data. Status code: ${response.statusCode}');
      }
    } catch (exception) {
      // Handle exception
      print('Exception occurred while submitting data: $exception');
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
                            'Favourite Hero',
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
                        controller:
                            heroController, // Your controller for handling the input
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: ThemeService.primary),
                          ),
                          prefixIcon:
                              Icon(Icons.star), // Icon for password input
                          hintText: 'Enter Favourite Hero',
                        ),
                        validator: (hero) {
                          if (hero == null || hero.isEmpty) {
                            return 'Please your favourite hero name';
                          } else if (hero.length < 4) {
                            return 'Name must be at least 4 characters long';
                          } else if (!RegExp(r'^[a-zA-Z]+$').hasMatch(hero)) {
                            return 'Sorry! only letters (a-z) are allowed';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            'Favourite Color',
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
                        controller:
                            colorController, // Your controller for handling the input
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: ThemeService.primary),
                          ),
                          prefixIcon:
                              Icon(Icons.color_lens), // Icon for password input
                          hintText: 'Enter Favourite Color',
                        ),
                        validator: (color) {
                          if (color == null || color.isEmpty) {
                            return 'Enter your favourite color';
                          } else if (color.length < 3) {
                            return 'color must be at least 3 characters long';
                          } else if (!RegExp(r'^[a-zA-Z]+$').hasMatch(color)) {
                            return 'Sorry! only letters (a-z) are allowed';
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
                                String hero = heroController.text;
                                String color = colorController.text;
                                if (widget.status == 200) {
                                  submitUserData(widget.mobile, hero, color);
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SetPasswordPage(
                                            mobile: widget.mobile,
                                            hero: hero,
                                            color: color,
                                            status: 0)),
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
