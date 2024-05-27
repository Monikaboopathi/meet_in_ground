import 'package:flutter/material.dart';
import 'package:meet_in_ground/Screens/authenticate/password_page.dart';
import 'package:meet_in_ground/constant/themes_service.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

void main() {
  runApp(LoginPage());
}

class LoginPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController mobileController = TextEditingController();

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
                        decoration: InputDecoration(
                          labelText: 'Mobile Number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
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
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PasswordPage()),
                            );
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
                    GestureDetector(
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                        onPressed: () {
                          if (_referralFormKey.currentState!.validate()) {
                            // Handle referral code submission
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
