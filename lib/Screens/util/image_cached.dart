// ignore_for_file: avoid_unnecessary_containers, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meet_in_ground/constant/themes_service.dart';

class CachedImage extends StatefulWidget {
  final String? imageURL;

  const CachedImage(this.imageURL, {Key? key}) : super(key: key);

  @override
  _CachedImageState createState() => _CachedImageState();
}

class _CachedImageState extends State<CachedImage> {
  @override
  Widget build(BuildContext context) {
    return widget.imageURL!.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: widget.imageURL ?? "",
            fit: BoxFit.cover,
            width: double.infinity,
            placeholder: (context, url) => Container(
              child: Center(
                child: CircularProgressIndicator(
                  color: ThemeService.textColor,
                ),
              ),
            ), // You can customize the placeholder
            errorWidget: (context, url, error) => Image.network(
              'https://notification-traininfo.s3.amazonaws.com/images/1710686685926-updatedRateUs.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          )
        : Image.asset(
            'assets/img-not-found.png',
            fit: BoxFit.cover,
            width: double.infinity,
          );
  }
}
