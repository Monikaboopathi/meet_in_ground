// import 'dart:io';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// class AdHelper {
//   static String get bannerAdUnitId {
//     String BANNER_AND = dotenv.get("BANNER_AND", fallback: null);
//     String BANNER_IOS = dotenv.get("BANNER_IOS", fallback: null);
//     if (Platform.isAndroid) {
//       return BANNER_AND;
//     } else if (Platform.isIOS) {
//       return BANNER_IOS;
//     } else {
//       throw new UnsupportedError('Unsupported platform');
//     }
//   }

//   static String get interstitialAdUnitId {
//     String INTERSTITIAL_AND = dotenv.get("INTERSTITIAL_AND", fallback: null);
//     String INTERSTITIAL_IOS = dotenv.get("INTERSTITIAL_IOS", fallback: null);
//     if (Platform.isAndroid) {
//       return INTERSTITIAL_AND;
//     } else if (Platform.isIOS) {
//       return INTERSTITIAL_IOS;
//     } else {
//       throw new UnsupportedError('Unsupported platform');
//     }
//   }

//   static String get rewardedAdUnitId {
//     String REWARDED_AND = dotenv.get("REWARDED_AND", fallback: null);
//     String REWARDED_IOS = dotenv.get("REWARDED_IOS", fallback: null);

//     if (Platform.isAndroid) {
//       return REWARDED_AND;
//     } else if (Platform.isIOS) {
//       return REWARDED_IOS;
//     } else {
//       throw new UnsupportedError('Unsupported platform');
//     }
//   }

//   static String get rewardedInterstitialAd {
//     String REWARDED_INT_AND = dotenv.get("REWARDED_INT_AND", fallback: null);
//     String REWARDED_INT_IOS = dotenv.get("REWARDED_INT_IOS", fallback: null);
//     if (Platform.isAndroid) {
//       return REWARDED_INT_AND;
//     } else if (Platform.isIOS) {
//       return REWARDED_INT_IOS;
//     } else {
//       throw new UnsupportedError('Unsupported platform');
//     }
//   }

//   static String get nativeAdUnitId {
//     String NATIVE_AND = dotenv.get("NATIVE_AND", fallback: null);
//     String NATIVE_IOS = dotenv.get("NATIVE_IOS", fallback: null);
//     if (Platform.isAndroid) {
//       return NATIVE_AND;
//     } else if (Platform.isIOS) {
//       return NATIVE_IOS;
//     }
//     throw new UnsupportedError("Unsupported platform");
//   }
// }
