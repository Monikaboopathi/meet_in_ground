import 'package:flutter/material.dart';
import 'package:meet_in_ground/Screens/Profile/ProfileDetailItem.dart';
import 'package:meet_in_ground/constant/themes_service.dart';

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
            text:userDetails['location'] ?? 'Unknown location',
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