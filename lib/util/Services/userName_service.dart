import 'package:shared_preferences/shared_preferences.dart';

class UsernameService {
  static Future<void> saveUserName(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_username', username);
  }

  static Future<String?> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_username');
  }

  static Future<void> clearUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_username');
  }
}
