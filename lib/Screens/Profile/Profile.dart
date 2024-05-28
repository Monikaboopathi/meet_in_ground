import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:clipboard/clipboard.dart';
import 'package:meet_in_ground/constant/themes_service.dart';
import 'package:http/http.dart' as http;
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
  bool isLoading = true;
  bool modalVisible = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    var response = await http.get(Uri.parse(
        'https://bet-x-new.onrender.com/user/viewUserProfile/8072974576'));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['data'];

      setState(() {
        userDetails = {
          'profileImg': data['userDetails']['profileImg'],
          'userName': data['userDetails']['userName'],
          'phoneNumber': data['userDetails']['phoneNumber'],
          'location': jsonDecode(data['userDetails']['location'])['coords']
              ['accuracy'],
          'sport': data['userDetails']['sport'],
          'referralId': data['userDetails']['referralId']
        };

        referralDetails = {
          'registeredUserCount': data['referralDetails']['registeredUserCount']
        };

        referredPost = data['myRequestsCount'].toString();

        userCity = ''; // You can parse the location data to get the city
        balance = '0'; // You need to fetch balance data from the API
        notificationData =
            []; // You need to fetch notification data from the API

        isLoading = false;
      });
    } else {
      throw Exception('Failed to load user details');
    }
  }

  void handleLogout() {
    // Perform logout operations
    Navigator.pushReplacementNamed(context, '/login');
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
      body: isLoading
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
                  if (modalVisible)
                    RatingDialog(
                      rating: rating,
                      onClose: () {
                        setState(() {
                          modalVisible = false;
                        });
                      },
                    ),
                ],
              ),
            ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final Map<String, dynamic> userDetails;
  final String userCity;
  final VoidCallback onEditProfile;

  ProfileHeader({
    required this.userDetails,
    required this.userCity,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 20,
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: Icon(Icons.edit, color: ThemeService.textColor),
              onPressed: onEditProfile,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: userDetails['profileImg'] != null
                      ? NetworkImage(userDetails['profileImg'])
                      : AssetImage('assets/images/empty-img.jpg')
                          as ImageProvider,
                ),
                SizedBox(height: 10),
                Text(
                  userDetails['userName'],
                  style: TextStyle(
                    color: ThemeService.textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileDetails extends StatelessWidget {
  final Map<String, dynamic> userDetails;

  ProfileDetails({required this.userDetails});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ThemeService.transparent,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: ThemeService.transparent,
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileDetailItem(
            icon: Icons.location_on,
            text: 'Unknown location',
            copy: false,
          ),
          ProfileDetailItem(
            icon: Icons.phone,
            text: userDetails['phoneNumber'] ?? 'Unknown phone number',
            copy: false,
          ),
          ProfileDetailItem(
            icon: Icons.sports_esports,
            text: userDetails['sport'] ?? 'Unknown sport',
            copy: false,
          ),
          ProfileDetailItem(
            icon: Icons.content_copy,
            text: userDetails['referralId'] ?? 'No referral ID',
            copy: true,
          ),
        ],
      ),
    );
  }
}

class ProfileDetailItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool copy;

  ProfileDetailItem(
      {required this.icon, required this.text, required this.copy});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          copy ? Container() : Icon(icon, color: ThemeService.textColor),
          SizedBox(width: copy ? 0 : 10),
          Expanded(
            child: copy
                ? GestureDetector(
                    onTap: () {
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
                    },
                    child: Row(
                      children: [
                        Icon(Icons.copy, color: ThemeService.textColor),
                        SizedBox(width: 5),
                        Text(
                          text,
                          style: TextStyle(
                            color: ThemeService.textColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : Text(
                    text,
                    style: TextStyle(
                      color: ThemeService.textColor,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
        ],
      ),
    );
  }
}

class FeaturesSection extends StatelessWidget {
  final String balance;
  final int notificationCount;
  final String referredPost;
  final Map<String, dynamic> referralDetails;
  final VoidCallback onRateUs;
  final VoidCallback onShareUs;

  FeaturesSection({
    required this.balance,
    required this.notificationCount,
    required this.referredPost,
    required this.referralDetails,
    required this.onRateUs,
    required this.onShareUs,
  });

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> features = [
      {
        'icon': Icons.account_balance_wallet,
        'featureName': 'Wallet',
        'leadText': '₹ ${balance.toString()}',
        'navigate': '/wallet',
        'onPress': null,
      },
      {
        'icon': Icons.notifications_active,
        'featureName': 'Notifications',
        'leadText': '$notificationCount',
        'navigate': '/notifications',
        'onPress': null,
      },
      {
        'icon': Icons.note,
        'featureName': 'Requested Posts',
        'leadText': referredPost,
        'navigate': '/requestedPosts',
        'onPress': null,
      },
      {
        'icon': Icons.feedback,
        'featureName': 'Feedback',
        'leadText': '',
        'navigate': '/feedback',
        'onPress': null,
      },
      {
        'icon': Icons.flag,
        'featureName': 'Raise Issue',
        'leadText': '',
        'navigate': '/issues',
        'onPress': null,
      },
      {
        'icon': Icons.group,
        'featureName': 'Referred Users',
        'leadText': referralDetails['registeredUserCount'].toString(),
        'navigate': '/referredUsers',
        'onPress': null,
      },
      {
        'icon': Icons.star,
        'featureName': 'Rate Us',
        'leadText': '',
        'navigate': '',
        'onPress': onRateUs,
      },
      {
        'icon': Icons.share,
        'featureName': 'Share Us',
        'leadText': '',
        'navigate': '',
        'onPress': onShareUs,
      },
    ];

    return Column(
      children: features.map((feature) {
        return Column(
          children: [
            ListTile(
              leading: Icon(feature['icon'], color: ThemeService.textColor),
              title: Text(
                feature['featureName'],
                style: TextStyle(color: ThemeService.textColor, fontSize: 12),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (feature['leadText'].isNotEmpty)
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        feature['leadText'],
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  Icon(Icons.chevron_right, color: ThemeService.textColor),
                ],
              ),
              onTap: () {
                if (feature['navigate'] != "") {
                  Navigator.pushNamed(context, feature['navigate']);
                } else if (feature['onPress'] != null) {
                  feature['onPress']();
                }
              },
            ),
            Divider(color: Colors.grey),
          ],
        );
      }).toList(),
    );
  }
}

class RatingDialog extends StatelessWidget {
  final double rating;
  final VoidCallback onClose;

  RatingDialog({required this.rating, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Rate Us'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Please rate our app'),
          // Add a rating widget here
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: onClose,
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ProfileScreen(),
    routes: {
      '/login': (context) => LoginScreen(),
      '/editProfile': (context) => EditProfileScreen(),
      // Define other routes here
    },
  ));
}

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Login Screen')),
    );
  }
}

class EditProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: Center(child: Text('Edit Profile Screen')),
    );
  }
}
