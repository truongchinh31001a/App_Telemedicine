import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:teleapp/utils/auth_storage.dart';

class FormExportService {
  static const String _baseUrl = 'http://192.168.1.197:3050/api';

  static Future<bool> exportForm({
    required String endpoint,
    required int recordId,
    required Map<String, dynamic> formData,
  }) async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      print('❌ Không tìm thấy token');
      return false;
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        ...formData,
        'recordId': recordId,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
