import 'package:flutter/material.dart';
import 'package:meet_in_ground/Screens/Feedback/feedback_page.dart';
import 'package:meet_in_ground/Screens/Issues/issues_page.dart';
import 'package:meet_in_ground/Screens/notification/Notification_page.dart';
import 'package:meet_in_ground/Screens/requestedPosts/RequestedPosts.dart';
import 'package:meet_in_ground/Screens/wallet/Wallet_page.dart';
import 'package:meet_in_ground/constant/themes_service.dart';
import 'package:meet_in_ground/widgets/RateUs.dart';

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
    void RateUs() {
      showDialogRateUs(context);
    }

    List<Map<String, dynamic>> features = [
      {
        'icon': Icons.account_balance_wallet,
        'featureName': 'Wallet',
        'leadText': '₹ ${balance}',
        'navigate': WalletPage(),
        'onPress': null,
      },
      {
        'icon': Icons.notifications_active,
        'featureName': 'Notifications',
        'leadText': '$notificationCount',
        'navigate': Notificationspage(),
        'onPress': null,
      },
      {
        'icon': Icons.note,
        'featureName': 'Requested Posts',
        'leadText': referredPost.isEmpty ? "0" : referredPost,
        'navigate': RequestedPosts(),
        'onPress': null,
      },
      {
        'icon': Icons.feedback,
        'featureName': 'Feedback',
        'leadText': '',
        'navigate': Feedbackpage(),
        'onPress': null,
      },
      {
        'icon': Icons.flag,
        'featureName': 'Raise Issue',
        'leadText': '',
        'navigate': ReportIssuesPage(),
        'onPress': null,
      },
      {
        'icon': Icons.group,
        'featureName': 'Referred Users',
        'leadText': referralDetails['registeredUserCount'].toString().isEmpty
            ? "0"
            : referralDetails['registeredUserCount'].toString(),
        'navigate': 'referredUsers',
        'onPress': null,
      },
      {
        'icon': Icons.star,
        'featureName': 'Rate Us',
        'leadText': '',
        'navigate': '',
        'onPress': RateUs,
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
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => feature['navigate'],
                    ),
                  );
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
