import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionManager {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveSession(String email, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
    await _storage.write(key: 'auth_token', value: token);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  static Future<String?> getAuthToken() async {
    return await _storage.read(key: 'auth_token');
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    await _storage.delete(key: 'auth_token');
  }
}