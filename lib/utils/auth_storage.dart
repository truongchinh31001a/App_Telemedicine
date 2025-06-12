import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';

class AuthStorage {
  /// Lưu access_token (dưới key 'token'), refresh_token, và user info
  static Future<void> save(String accessToken, String refreshToken) async {
    final decoded = JwtDecoder.decode(accessToken);

    final user = {
      'userId': decoded['userId'],
      'username': decoded['username'],
      'roleId': decoded['roleId'],
      'staffId': decoded['staffId'],
      'patientId': decoded['patientId'],
    };

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', accessToken);              // dùng key 'token'
    await prefs.setString('refresh_token', refreshToken);
    await prefs.setString('user', jsonEncode(user));
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');                          // access_token
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    return userStr != null ? jsonDecode(userStr) : null;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');               // xoá access_token
    await prefs.remove('refresh_token');
    await prefs.remove('user');
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && !JwtDecoder.isExpired(token);
  }
}
