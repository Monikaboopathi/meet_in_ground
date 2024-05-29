// ignore: unused_import
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<String> getFcmToken() async {
    await _firebaseMessaging.requestPermission();
    String? fcmToken = await _firebaseMessaging.getToken();
    return fcmToken ?? 'token';
  }

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    // ignore: unused_local_variable
    final FCMToken = await _firebaseMessaging.getToken();
    // You can call the API function here if needed
    // sendFCMTokenToBackend(FCMToken!);
  }

  // Removed the sendFCMTokenToBackend function
}
