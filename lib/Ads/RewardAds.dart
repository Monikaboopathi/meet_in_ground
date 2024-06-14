// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';

// import '../../../Ads/ad_helper.dart';

// class AdMobReward extends StatefulWidget {
//   @override
//   _AdMobRewardState createState() => _AdMobRewardState();
// }

// class _AdMobRewardState extends State<AdMobReward> {
//   static final AdRequest request = AdRequest();
//   int maxFailedLoadAttempts = 3;
//   int life = 0;
//   RewardedAd? _rewardedAd;
//   int _numRewardedLoadAttempts = 0;
//   bool _adShown = false;

//   @override
//   void initState() {
//     super.initState();
//     _createRewardedAd();
//   }

//   void _createRewardedAd() {
//     RewardedAd.load(
//         adUnitId: AdHelper.rewardedAdUnitId,
//         request: request,
//         rewardedAdLoadCallback: RewardedAdLoadCallback(
//           onAdLoaded: (RewardedAd ad) {
//             print('$ad loaded.');
//             _rewardedAd = ad;
//             _numRewardedLoadAttempts = 0;
//             if (!_adShown) {
//               _showRewardedAd();
//             }
//           },
//           onAdFailedToLoad: (LoadAdError error) {
//             print('RewardedAd failed to load: $error');
//             _rewardedAd = null;
//             _numRewardedLoadAttempts += 1;
//             if (_numRewardedLoadAttempts < maxFailedLoadAttempts) {
//               _createRewardedAd();
//             }
//           },
//         ));
//   }

//   void _showRewardedAd() {
//     if (_rewardedAd == null) {
//       print('Warning: attempt to show rewarded before loaded.');
//       return;
//     }
//     _adShown = true;
//     _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
//       onAdShowedFullScreenContent: (RewardedAd ad) =>
//           print('ad onAdShowedFullScreenContent.'),
//       onAdDismissedFullScreenContent: (RewardedAd ad) {
//         print('$ad onAdDismissedFullScreenContent.');
//         ad.dispose();
//         _createRewardedAd();
//       },
//       onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
//         print('$ad onAdFailedToShowFullScreenContent: $error');
//         ad.dispose();
//         _createRewardedAd();
//       },
//     );

//     _rewardedAd!.setImmersiveMode(true);
//     _rewardedAd!.show(
//         onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
//       setState(() {
//         life += 1;
//       });
//     });
//     _rewardedAd = null;
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _rewardedAd?.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     _showRewardedAd();
//     return Container();
//   }
// }
