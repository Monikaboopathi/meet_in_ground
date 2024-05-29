import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meet_in_ground/Screens/authenticate/favourite_page.dart';
import 'package:meet_in_ground/Screens/authenticate/password_page.dart';
import 'package:meet_in_ground/constant/themes_service.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:http/http.dart' as http;
import 'package:meet_in_ground/util/Services/mobileNo_service.dart';
import 'package:meet_in_ground/util/Services/refferral_service.dart';
import 'package:meet_in_ground/util/api/Firebase_service.dart';
import 'package:meet_in_ground/widgets/Loader.dart';

String fcmToken = "";

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController mobileController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getToken();
  }

  void getToken() async {
    await Firebase.initializeApp();

    setState(() async {
      fcmToken = await FirebaseApi().getFcmToken();
    });

    print('FCM Token: $fcmToken');
  }

  Future<void> loginUser(String phoneNumber) async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse('https://bet-x-new.onrender.com/user/login'),
        body: jsonEncode({'phoneNumber': phoneNumber}),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PasswordPage(
              mobile: phoneNumber,
            ),
          ),
        );

        await MobileNo.clearMobilenumber();
      } else {
        Fluttertoast.showToast(
          msg: responseData['message'] ?? "New User",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => FavouritePage(
              mobile: phoneNumber,
              status: 0,
            ),
          ),
        );
        await MobileNo.clearMobilenumber();
      }
    } catch (exception) {
      print(exception);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Let's Play...",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: ThemeService.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      child: IntlPhoneField(
                        controller: mobileController,
                        disableLengthCheck: false,
                        decoration: InputDecoration(
                          labelText: 'Mobile Number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          counterText: "",
                        ),
                        initialCountryCode: 'IN',
                        
                        validator: (phone) {
                          if (phone == null || phone.number.isEmpty) {
                            return 'Please enter a valid mobile number';
                          }
                          return null;
                        },
                        onChanged: (phone) {
                          print(phone.completeNumber);
                        },
                      ),
                    ),
                    SizedBox(height: 30),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            String phonenumber = mobileController.text;
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return Loader();
                              },
                            );
                            await loginUser(phonenumber);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          backgroundColor: ThemeService.primary,
                        ),
                        child: Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    // ignore: unnecessary_null_comparison
                    RefferalService.getRefferal() != null
                        ? Center(
                            child: GestureDetector(
                              onTap: () {
                                _showDialogReferrel(context);
                              },
                              child: Text(
                                "Have a referral?",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> referralPost(String referralId) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
            'https://bet-x-new.onrender.com/user/verifyReferralID/$referralId'),
        body: jsonEncode({
          "referralId": referralId,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        String referralId = responseData['referralId'];

        await RefferalService.saveRefferal(referralId);

        Fluttertoast.showToast(
          msg: responseData['message'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(
          msg: responseData['error'] ??
              'Login failed. Please check your mobile number.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        setState(() {
          Navigator.pop(context);
          _showDialogReferrel(context);
        });
      }
    } catch (exception) {
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showDialogReferrel(BuildContext context) {
    final _referralFormKey = GlobalKey<FormState>();
    TextEditingController referralController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: AlertDialog(
            insetPadding: EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            content: Container(
              height: 200,
              width: 350,
              child: Form(
                key: _referralFormKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Enter Referral Code",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.close,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        controller: referralController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          prefixIcon: Icon(Icons.code),
                          hintText: 'Enter Referral Code',
                        ),
                        validator: (referralCode) {
                          if (referralCode == null || referralCode.isEmpty) {
                            return 'Please enter a Referral Code';
                          }
                          return null; // Return null if validation succeeds
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_referralFormKey.currentState!.validate()) {
                            // Handle referral code submission
                            String refferal = referralController.text;
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return Loader();
                              },
                            );
                            await referralPost(refferal);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          backgroundColor: ThemeService.primary,
                          padding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            'Submit',
                            style: TextStyle(
                              fontSize: 15,
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
          ),
        );
      },
    );
  }
}
