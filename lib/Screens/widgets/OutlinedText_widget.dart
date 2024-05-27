// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:meet_in_ground/constant/themes_service.dart';

class OutlinedText_widget extends StatelessWidget {
  final IconData iconData;
  final String text;

  const OutlinedText_widget({
    Key? key,
    required this.iconData,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: ThemeService.textColor,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      child: Row(
        children: [
          Icon(
            iconData,
            color: ThemeService.textColor,
            size: 15,
          ),
          SizedBox(width: 2.0),
          Text(
            text,
            style: TextStyle(fontSize: 12.0, color: ThemeService.textColor),
          ),
        ],
      ),
    );
  }
}
