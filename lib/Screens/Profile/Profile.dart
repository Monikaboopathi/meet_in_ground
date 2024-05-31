import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:clipboard/clipboard.dart';
import 'package:meet_in_ground/Screens/Profile/FeaturesSection.dart';
import 'package:meet_in_ground/Screens/Profile/ProfileDetails.dart';
import 'package:meet_in_ground/Screens/Profile/ProfileHeader.dart';
import 'package:meet_in_ground/Screens/authenticate/login_page.dart';
import 'package:meet_in_ground/constant/themes_service.dart';
import 'package:http/http.dart' as http;
import 'package:meet_in_ground/util/Services/mobileNo_service.dart';
import 'package:meet_in_ground/widgets/Loader.dart';
import 'package:meet_in_ground/widgets/ShareMethods.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> userDetails = {};
  Map<String, dynamic> referralDetails = {};
  String userCity = "";
  String referredPost = "";
  String userPhone = "";
  String balance = "";
  List<dynamic> notificationData = [];
  double rating = 0.0;
  bool isLoading = false;
  bool modalVisible = false;
  String? currentMobileNumber;

  @override
  void initState() {
    super.initState();
    initializeData().then((mobileNumber) {
      if (mounted) {
        setState(() {
          currentMobileNumber = mobileNumber!;
          fetchData();
        });
      }
    });
  }

  Future<String?> initializeData() async {
    try {
      String? number = await MobileNo.getMobilenumber() ?? "";
      return number;
    } catch (exception) {
      print(exception);
    }
    return null;
  }

  Future<void> fetchData() async {
    try {
      setState(() {
        isLoading = true;
      });
      var response = await http.get(Uri.parse(
          'https://bet-x-new.onrender.com/user/viewUserProfile/8072974576'));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body)['data'];

        setState(() {
          userDetails = {
            'profileImg': data['userDetails']['profileImg'],
            'userName': data['userDetails']['userName'],
            'phoneNumber': data['userDetails']['phoneNumber'],
            'location': "",
            'sport': data['userDetails']['sport'],
            'referralId': data['userDetails']['referralId']
          };

          referralDetails = {
            'registeredUserCount': data['referralDetails']
                ['registeredUserCount']
          };

          referredPost = data['myRequestsCount'].toString();

          userCity = '';
          balance = data['referralDetails']['referralUserWallet'].toString();
          notificationData = [];
        });
      } else {
        throw Exception('Failed to load user details');
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Future<String> getAddressFromLatLng(double lat, double lng) async {
  //   try {
  //     List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
  //     print(placemarks);
  //     Placemark place = placemarks[0];
  //     return "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
  //   } catch (e) {
  //     return 'Error getting address';
  //   }
  // }

  Future<void> _refresh() async {
    await fetchData();
  }

  void handleLogout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void copyToClipboard(String text) {
    FlutterClipboard.copy(text).then((_) {
      Fluttertoast.showToast(
          msg: "Referral copied to clipboard!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeService.background,
        title: Text(
          'Profile',
          style: TextStyle(
            color: ThemeService.textColor,
            fontFamily: 'Billabong',
            fontSize: 25,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: ThemeService.background,
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: isLoading
            ? Loader()
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ProfileHeader(
                      userDetails: userDetails,
                      userCity: userCity,
                      onEditProfile: () {
                        Navigator.pushNamed(context, '/editProfile');
                      },
                    ),
                    ProfileDetails(userDetails: userDetails),
                    FeaturesSection(
                      balance: balance.toString(),
                      notificationCount: notificationData.length,
                      referredPost: referredPost,
                      referralDetails: referralDetails,
                      onRateUs: () {
                        setState(() {
                          modalVisible = true;
                        });
                      },
                      onShareUs: () {
                        shareApp();
                      },
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: handleLogout,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            backgroundColor: ThemeService.buttonBg,
                          ),
                          child: Text(
                            'Logout',
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
      ),
    );
  }
}
