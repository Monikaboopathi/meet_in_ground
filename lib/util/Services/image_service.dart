import 'package:shared_preferences/shared_preferences.dart';

class ImageService {
  static Future<void> saveImage(String image) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_image', image);
  }

  static Future<String?> getImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_image');
  }

  static Future<void> clearImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_image');
  }
}
