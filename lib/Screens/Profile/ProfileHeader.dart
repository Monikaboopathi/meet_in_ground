import 'package:flutter/material.dart';
import 'package:meet_in_ground/constant/themes_service.dart';

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
    // Providing default values if userDetails keys are null
    final profileImg =
        userDetails['profileImg'] ?? 'assets/images/empty-img.jpg';
    final userName = userDetails['userName'] ?? 'Unknown User';

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
                  backgroundImage: profileImg.startsWith('http')
                      ? NetworkImage(profileImg)
                      : AssetImage(profileImg) as ImageProvider,
                ),
                SizedBox(height: 10),
                Text(
                  userName,
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
