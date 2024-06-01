import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static Future<void> saveValue(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<String?> getValue(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> clearValue(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
