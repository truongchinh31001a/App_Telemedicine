import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AppointmentService {
  static const String _baseUrl = 'http://192.168.1.197:3000/api';

  static Future<List<Map<String, dynamic>>> fetchAppointmentsByPatient() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token');
    final userString = prefs.getString('user');

    if (token == null || userString == null) {
      throw Exception('⚠️ Bạn chưa đăng nhập.');
    }

    final user = jsonDecode(userString);
    final patientId = user['patientId'];

    if (patientId == null) {
      throw Exception('❌ Tài khoản hiện tại không phải bệnh nhân.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/appointments/patient/$patientId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('❌ Lỗi khi tải lịch hẹn: ${response.statusCode}');
    }
  }
}
