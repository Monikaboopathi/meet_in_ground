// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import '../../../Ads/ad_helper.dart';

// class AdMobInterstitial extends StatefulWidget {
//   @override
//   _AdMobInterstitialState createState() => _AdMobInterstitialState();
// }

// class _AdMobInterstitialState extends State<AdMobInterstitial> {
//   static final AdRequest request = AdRequest();

//   int maxFailedLoadAttempts = 1;
//   InterstitialAd? _interstitialAd;
//   int _numInterstitialLoadAttempts = 0;
//   bool _adShown = false;
//   bool _isPremiumUser = false;
//   DateTime? premiumExpiration;

//   @override
//   void initState() {
//     super.initState();
//     _createInterstitialAd();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _interstitialAd?.dispose();
//   }

//   void _createInterstitialAd() {
//     InterstitialAd.load(
//       adUnitId: AdHelper.interstitialAdUnitId,
//       request: request,
//       adLoadCallback: InterstitialAdLoadCallback(
//         onAdLoaded: (InterstitialAd ad) {
//           print('$ad loaded');
//           _interstitialAd = ad;
//           _numInterstitialLoadAttempts = 0;
//           _interstitialAd!.setImmersiveMode(true);
//           if (!_adShown && !_isPremiumUser) {
//             _showInterstitialAd();
//           }
//         },
//         onAdFailedToLoad: (LoadAdError error) {
//           print('InterstitialAd failed to load: $error.');
//           _numInterstitialLoadAttempts += 1;
//           _interstitialAd = null;
//           if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
//             _createInterstitialAd();
//           }
//         },
//       ),
//     );
//   }

//   void _showInterstitialAd() {
//     if (_interstitialAd == null) {
//       print('Warning: attempt to show interstitial before loaded.');
//       return;
//     }

//     _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
//       onAdShowedFullScreenContent: (InterstitialAd ad) {
//         print('ad onAdShowedFullScreenContent.');
//         _adShown = true; // Mark the ad as shown
//       },
//       onAdDismissedFullScreenContent: (InterstitialAd ad) {
//         print('$ad onAdDismissedFullScreenContent.');
//         ad.dispose();
//         _createInterstitialAd();
//       },
//       onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
//         print('$ad onAdFailedToShowFullScreenContent: $error');
//         ad.dispose();
//         _createInterstitialAd();
//       },
//     );

//     _interstitialAd!.show();
//     _interstitialAd = null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }
