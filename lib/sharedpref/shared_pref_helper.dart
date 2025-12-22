import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  static const _keyLoggedIn = 'is_logged_in';
  static const _keyName = 'name';
  static const _keyUserSrNo = 'usersrno';
  static const _keyEmployeeSrNo = 'employeesrno';

  static Future<void> saveLoginData({
    required String name,
    required String userSrNo,
    required String employeeSrNo,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, true);
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyUserSrNo, userSrNo);
    await prefs.setString(_keyEmployeeSrNo, employeeSrNo);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<String?> getUserSrNo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserSrNo);
  }

  static Future<String?> getEmployeeSrNo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmployeeSrNo);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyName);
  }
}
