import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meet_in_ground/constant/themes_service.dart';

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