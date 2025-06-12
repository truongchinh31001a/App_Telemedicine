import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:teleapp/utils/auth_storage.dart';

class MedicalHistoryService {
  static Future<Map<String, dynamic>> fetchMedicalHistory() async {
    final user = await AuthStorage.getUser();
    final token = await AuthStorage.getToken();

    if (user == null || user['patientId'] == null || token == null) {
      throw Exception("Không có thông tin xác thực");
    }

    final patientId = user['patientId'];
    final url = 'http://192.168.1.199:3000/medical-records/history/$patientId';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Lỗi lấy bệnh sử: ${response.statusCode}');
    }
  }
}
