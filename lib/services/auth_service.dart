import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:teleapp/utils/auth_storage.dart';

class AuthService {
  static const String _baseUrl = 'http://192.168.1.199:3000';

  static Future<void> changePassword(
    String oldPassword,
    String newPassword,
  ) async {
    final token = await AuthStorage.getToken();

    if (token == null) {
      throw Exception('Không tìm thấy token. Vui lòng đăng nhập lại.');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/auth/change-password'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      final message = body['error'] ?? 'Đổi mật khẩu thất bại';
      throw Exception(message);
    }
  }

  static Future<String> sendOtp(String email) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200 && body['otpSessionId'] != null) {
      return body['otpSessionId'];
    } else {
      final message = body['error'] ?? 'Gửi OTP thất bại';
      throw Exception(message);
    }
  }

  static Future<void> verifyOtp(String sessionId, String otp) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'otpSessionId': sessionId, 'otp': otp}),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode != 200) {
      final message = body['error'] ?? 'Xác minh OTP thất bại';
      throw Exception(message);
    }
  }

  static Future<void> resetPassword(
    String sessionId,
    String newPassword,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'otpSessionId': sessionId, 'newPassword': newPassword}),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode != 200) {
      final message = body['error'] ?? 'Đặt lại mật khẩu thất bại';
      throw Exception(message);
    }
  }
}
