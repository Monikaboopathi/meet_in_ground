// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meet_in_ground/Screens/wallet/Wallet_page.dart';
import 'package:meet_in_ground/constant/themes_service.dart';
import 'package:meet_in_ground/util/Services/mobileNo_service.dart';
import 'package:meet_in_ground/util/Services/refferral_service.dart';
import 'package:meet_in_ground/widgets/ShareMethods.dart';
import 'package:meet_in_ground/widgets/T&C.dart';

void main() {
  runApp(ReferEarn());
}

class ReferEarn extends StatefulWidget {
  @override
  _ReferEarnState createState() => _ReferEarnState();
}

class _ReferEarnState extends State<ReferEarn> with TickerProviderStateMixin {
  late String storedMobile;
  late String storedRefferal;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initializeData() async {
    try {
      storedMobile = (await MobileNo.getMobilenumber()) ?? '';
      storedRefferal = (await RefferalService.getRefferal()) ?? '';
    } catch (exception) {
      print(exception);
    }

    setState(() {});

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeService.background,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: ThemeService.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Refer & Earn",
              style: TextStyle(
                color: ThemeService.textColor,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ],
        ),
        iconTheme: IconThemeData(color: ThemeService.textColor, size: 35),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 10, 16, 10),
                  child: Card(
                    color: ThemeService.transparent,
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                child: Text(
                                  "How It Works",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: ThemeService.primary,
                                  ),
                                  softWrap: true,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            TermsandCondition()),
                                  );
                                },
                                child: Text(
                                  'T&C\'s',
                                  style: TextStyle(color: ThemeService.primary),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 10),
                          buildNumberedText(
                              1, "Share your referral link with friends."),
                          SizedBox(
                            height: 10,
                          ),
                          buildNumberedText(2,
                              "Ask your friends to sign up using your link."),
                          SizedBox(
                            height: 10,
                          ),
                          buildNumberedText(3,
                              "Once your friends log in, you will earn Rs.10 for each referral."),
                          SizedBox(
                            height: 10,
                          ),
                          buildNumberedText(4,
                              "Track your earnings and referrals in the app."),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 6, 16, 0),
                  child: Card(
                    color: ThemeService.transparent,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: ThemeService.textColor),
                                  children: [
                                    TextSpan(
                                        text: "Available for new users only",
                                        style: TextStyle(
                                            color: ThemeService.textColor)),
                                    TextSpan(
                                      text: '*',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Center(
                          child: _buildRefferal("Referral", Icons.offline_share,
                              storedRefferal, () {}),
                        ),
                        Center(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Copy this Code",
                            style: TextStyle(
                                fontSize: 12, color: ThemeService.textColor),
                          ),
                        ))
                      ],
                    ),
                  ),
                ),
                // Button on top
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    color: ThemeService.transparent,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 250,
                            child: ElevatedButton(
                              onPressed: () async {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => WalletPage()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                backgroundColor: ThemeService.buttonBg,
                              ),
                              child: Text(
                                "Check Your Balance",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  height: 15,
                ),
                // Button for "Invite Now"
                ElevatedButton(
                  onPressed: () {
                    shareApp();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    backgroundColor: Colors.green,
                    side: BorderSide(color: Colors.black), // Border color
                  ),
                  child: Text(
                    "Invite Now",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefferal(
      String title, IconData icon, String content, VoidCallback onPressed) {
    bool isLoggedIn = storedMobile.isNotEmpty ? true : false;

    if (content.isNotEmpty && isLoggedIn) {
      return ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: ThemeService.primary,
          ),
        ),
        subtitle: Text(
          content,
          style: TextStyle(color: ThemeService.textColor),
        ),
        trailing: Icon(
          Icons.content_copy,
          size: 20,
          color: ThemeService.textColor,
        ),
        onTap: () {
          onPressed();
          _copyToClipboard(content);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'You can refer only one person per day, with a total of three referrals allowed.'),
            ),
          );
        },
      );
    } else {
      return SizedBox.shrink();
    }
  }

  void _copyToClipboard(String content) {
    Clipboard.setData(ClipboardData(text: content)).then((result) {});
  }

  Widget buildNumberedText(int number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$number.',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ThemeService.third),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Container(
            width: 250,
            child: Text(
              text,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: ThemeService.textColor),
              softWrap: true,
            ),
          ),
        ),
      ],
    );
  }
}
