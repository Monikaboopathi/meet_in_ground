// widgets/no_data_found_widget.dart
import 'package:flutter/material.dart';
import 'package:meet_in_ground/constant/themes_service.dart';

class NoDataFoundWidget extends StatelessWidget {
  final String imagePath;
  final double width;
  final double height;
  final String errorText;

  const NoDataFoundWidget(
      {Key? key,
      this.imagePath = 'assets/noData.png',
      this.width = 200.0,
      this.height = 200.0,
      required this.errorText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: ThemeService.background,
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: width,
              height: height,
            ),
            Text(
              errorText,
              style: TextStyle(
                  color: ThemeService.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
