import 'package:shared_preferences/shared_preferences.dart';

class RefferalService {
  static Future<void> saveRefferal(String referralId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_refferal', referralId);
  }

  static Future<String?> getRefferal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_refferal');
  }

  static Future<void> clearRefferal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_refferal');
  }
}
