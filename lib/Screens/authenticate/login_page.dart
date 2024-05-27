import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:meet_in_ground/constant/themes_service.dart';

void main() {
  runApp(LoginPage());
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/login.png',
                  width: MediaQuery.of(context).size.width,
                  height: 280,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Let's Play...",
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: ThemeService.primary),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CountryCodePicker(
                        onChanged: print,
                        initialSelection: 'US',
                        favorite: ['+1', 'US'],
                      ),
                      SizedBox(width: 10),
                      Container(
                        width: 200,
                        height: 50,
                        child: TextFormField(
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: "Mobile Number",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      backgroundColor: ThemeService.primary,
                      padding: EdgeInsets.symmetric(vertical: 10,horizontal: 70)
                    ),
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  GestureDetector(
                    onTap: () {
                      // Navigate to referral page
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
    );
  }
}
