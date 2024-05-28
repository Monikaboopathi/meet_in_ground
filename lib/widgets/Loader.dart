import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:meet_in_ground/constant/themes_service.dart';

class Loader extends StatelessWidget {
  final double width;
  final double height;

  const Loader({Key? key, this.width = 200, this.height = 200})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: ThemeService.background,
      child: Center(
        child: Lottie.asset(
          'assets/loader.json',
          width: width,
          height: height,
        ),
      ),
    );
  }
}
