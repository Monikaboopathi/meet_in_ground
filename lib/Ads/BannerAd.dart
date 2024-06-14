// import 'package:flutter/material.dart';

// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:meet_in_ground/Ads/ad_helper.dart';

// class AdMobBanner extends StatefulWidget {
//   @override
//   _AdMobBannerState createState() => _AdMobBannerState();
// }

// class _AdMobBannerState extends State<AdMobBanner> {
//   int maxFailedLoadAttempts = 3;
//   int life = 0;
//   late BannerAd _bannerAd;
//   bool _isBannerAdReady = false;
//   bool _showAds = true;
//   DateTime? premiumExpiration;

//   @override
//   void initState() {
//     super.initState();
//     _loadBannerAd();
//   }

//   void _loadBannerAd() {
//     _bannerAd = BannerAd(
//       adUnitId: AdHelper.bannerAdUnitId,
//       request: AdRequest(),
//       size: AdSize.banner,
//       listener: BannerAdListener(
//         onAdLoaded: (_) {
//           setState(() {
//             _isBannerAdReady = true;
//           });
//         },
//         onAdFailedToLoad: (ad, err) {
//           _isBannerAdReady = false;
//           ad.dispose();
//         },
//       ),
//     );

//     _bannerAd.load();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return _showAds
//         ? Container(
//             child: _isBannerAdReady
//                 ? Align(
//                     alignment: Alignment.bottomCenter,
//                     child: Container(
//                       width: _bannerAd.size.width.toDouble(),
//                       height: _bannerAd.size.height.toDouble(),
//                       child: AdWidget(ad: _bannerAd),
//                     ),
//                   )
//                 : Container(),
//           )
//         : SizedBox(); // Return an empty SizedBox if ads are not to be shown
//   }

//   @override
//   void dispose() {
//     _bannerAd.dispose();
//     super.dispose();
//   }
// }
