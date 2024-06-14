// import 'dart:developer';
// import 'package:get/get.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:meet_in_ground/Ads/Ad_Helper.dart';

// class NativeAdsController extends GetxController {
//   NativeAd? nativeAd;
//   RxBool isAdLoaded = false.obs;

//   loadAd() {
//     nativeAd = NativeAd(
//         adUnitId: AdHelper.nativeAdUnitId,
//         listener: NativeAdListener(
//           onAdLoaded: (ad) {
//             isAdLoaded.value = true;
//             log("Ad Loaded");
//           },
//           onAdFailedToLoad: (ad, error) {
//             isAdLoaded.value = false;
//           },
//         ),
//         request: const AdRequest(),
//         nativeTemplateStyle:
//             NativeTemplateStyle(templateType: TemplateType.small));
//     nativeAd!.load();
//   }

//   @override
//   void dispose() {
//     nativeAd?.dispose();
//     super.dispose();
//   }
// }
