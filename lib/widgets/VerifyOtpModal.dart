import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meet_in_ground/util/Services/mobileNo_service.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:meet_in_ground/constant/themes_service.dart';
import 'package:http/http.dart' as http;

class OtpModal extends StatefulWidget {
  final String email;

  OtpModal({required this.email});

  @override
  _OtpModalState createState() => _OtpModalState();
}

class _OtpModalState extends State<OtpModal> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();
  bool isLoading = false;

  void _submitOtp() {
    if (_formKey.currentState!.validate()) {
      String otp = _otpController.text;
      verifyEmailWithOTP(widget.email, otp, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              backgroundColor: ThemeService.primary,
              automaticallyImplyLeading: false,
              elevation: 0.0,
              title: Center(
                child: Text(
                  "Enter OTP",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 14.0,
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 25,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    PinCodeTextField(
                      appContext: context,
                      controller: _otpController,
                      length: 6,
                      keyboardType: TextInputType.number,
                      enablePinAutofill: true,
                      onChanged: (value) {},
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(10),
                        fieldHeight: 40,
                        fieldWidth: 40,
                        activeFillColor: Colors.white,
                        activeColor: ThemeService.primary,
                        inactiveColor: Colors.grey,
                        selectedColor: ThemeService.primary,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "OTP is Required";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: _submitOtp,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        backgroundColor: ThemeService.primary,
                      ),
                      child: Text(
                        "Submit",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void openOtpModal(BuildContext context, String email) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return OtpModal(email: email);
    },
  );
}

Future<void> verifyEmailWithOTP(String email, String otp, context) async {
  String Base_url = dotenv.get("BASE_URL", fallback: null);
  String? storedMobile = await MobileNo.getMobilenumber();

  final apiUrl = '${Base_url}/verifyEmail/$storedMobile';
  final requestBody = jsonEncode({'email': email});
  print('Request Body: $requestBody');
  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: requestBody,
    );

    if (response.statusCode == 200) {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: 'Email verified successfull',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } else {
      Fluttertoast.showToast(
        msg: 'Entered Wrong OTP',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  } catch (error) {
    print('Error: $error');
  }
}
