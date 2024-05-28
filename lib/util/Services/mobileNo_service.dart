import 'package:shared_preferences/shared_preferences.dart';

class MobileNo {
  static Future<void> saveMobilenumber(String mobilenumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('user_mobilenumber', mobilenumber);
  }

  static Future<String?> getMobilenumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_mobilenumber');
  }

  static Future<void> clearMobilenumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_mobilenumber');
  }

  // static Future<void> saveDefaultMobilenumber(String email) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String mobile = email.substring(3);
  //   await prefs.setString('default_user_email', mobile);
  // }

  // static Future<String?> getDefaultEmail() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   return prefs.getString('default_user_email');
  // }

  // static Future<void> clearDefaultEmail() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.remove('default_user_email');
  // }
}


class MobileNoStored {
  static const String _keyVerifiedMobilenumber = 'verified_Mobilenumber';

  static Future<String?> getUserMobilenumber() async {
    return null;
  
  }

  static Future<void> saveVerifiedMobilenumber(String mobilenumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyVerifiedMobilenumber, mobilenumber);
  }

  static Future<String?> getSavedVerifiedMobilenumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyVerifiedMobilenumber);
  }

  // Implement other Mobilenumber related functionalities as needed
}

