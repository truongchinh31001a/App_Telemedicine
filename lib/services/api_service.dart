import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:teleapp/screens/login_screen.dart';
import 'package:teleapp/utils/auth_storage.dart';
import 'package:teleapp/main.dart'; // chứa navigatorKey

class ApiService {
  static const String baseUrl = 'http://192.168.1.199:3000';

  // ==== AUTH ====

  static Future<http.Response> login(String username, String password) {
    return http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
  }

  static Future<http.Response> register(Map<String, dynamic> data) {
    return http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
  }

  static Future<http.Response> verifySms(String phone, String code) {
    return http.post(
      Uri.parse('$baseUrl/auth/verify-sms'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'code': code}),
    );
  }

  static Future<http.Response> changePassword(String current, String newPass) async {
    final token = await _getValidToken();
    return http.post(
      Uri.parse('$baseUrl/auth/change-password'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'currentPassword': current, 'newPassword': newPass}),
    );
  }

  // ==== AUTO TOKEN VALIDATION & REFRESH ====

  static Future<String> _getValidToken() async {
    final token = await AuthStorage.getToken();

    if (token == null || _isExpired(token)) {
      final success = await _refreshToken();
      if (!success) throw Exception('Phiên đăng nhập hết hạn');
    }

    final newToken = await AuthStorage.getToken();
    if (newToken == null) throw Exception('Không tìm thấy token');
    return newToken;
  }

  static bool _isExpired(String token) {
    try {
      return JwtDecoder.isExpired(token);
    } catch (_) {
      return true;
    }
  }

  static Future<bool> _refreshToken() async {
    final refreshToken = await AuthStorage.getRefreshToken();
    if (refreshToken == null) return false;

    final res = await http.post(
      Uri.parse('$baseUrl/auth/refresh-token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final newAccessToken = data['access_token'];
      final newRefreshToken = data['refresh_token'];

      if (newAccessToken != null && newRefreshToken != null) {
        await AuthStorage.save(newAccessToken, newRefreshToken);
        return true;
      }
    }

    await AuthStorage.clear();
    _redirectToLogin();
    return false;
  }

  static void _redirectToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = navigatorKey.currentContext;
      if (context != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    });
  }

  // ==== GENERIC REQUESTS WITH TOKEN ====

  static Future<http.Response> getWithToken(String endpoint) async {
    final token = await _getValidToken();
    return http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  static Future<http.Response> postWithToken(String endpoint, Map<String, dynamic> body) async {
    final token = await _getValidToken();
    return http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> putWithToken(String endpoint, Map<String, dynamic> body) async {
    final token = await _getValidToken();
    return http.put(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
  }
}
