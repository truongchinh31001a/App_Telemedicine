import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:teleapp/utils/auth_storage.dart';

class UserService {
  static const String _baseUrl = 'http://192.168.1.199:3000';

  static Future<Map<String, dynamic>> fetchPersonalInfo() async {
    final token = await AuthStorage.getToken();
    final user = await AuthStorage.getUser();
    final patientId = user?['patientId'];

    if (token == null || patientId == null) {
      throw Exception('Token hoặc patientId không tồn tại');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/patients/$patientId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Lỗi khi tải thông tin cá nhân: ${response.statusCode}\n${response.body}',
      );
    }
  }
}
