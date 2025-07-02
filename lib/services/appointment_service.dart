import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/appointment.dart';

class AppointmentService {
  static const String _baseUrl = 'http://192.168.1.199:3014/appointment/me';

  static Future<List<Appointment>> fetchAppointmentsByPatient() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) throw Exception('⚠️ Bạn chưa đăng nhập.');

    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Appointment.fromJson(e)).toList();
    } else {
      throw Exception('❌ Lỗi khi tải lịch hẹn: ${response.statusCode}');
    }
  }
}
