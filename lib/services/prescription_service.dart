import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:teleapp/utils/auth_storage.dart';

class PrescriptionService {
  static const String baseUrl = 'http://192.168.1.199:3000';

  static Future<Map<String, String>> _buildHeaders() async {
    final token = await AuthStorage.getToken();

    if (token == null || token.trim().isEmpty) {
      throw Exception('❌ Token không tồn tại hoặc bị rỗng');
    }

    final header = {'Authorization': 'Bearer $token'};

    return header;
  }

  /// Lấy danh sách đơn thuốc theo bệnh nhân
  static Future<List<Map<String, dynamic>>> getPrescriptionsByPatient(
    int patientId,
  ) async {
    final headers = await _buildHeaders();
    final url = Uri.parse('$baseUrl/prescriptions/patient/$patientId');

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final Map<int, Map<String, dynamic>> grouped = {};

      for (var item in data) {
        final recordId = item['record_id']; // ✅ đúng key
        if (!grouped.containsKey(recordId)) {
          grouped[recordId] = {
            'date': item['start_date'], // ✅ đúng key
            'doctor': 'BS. ${item['doctor_name']}', // ✅ đúng key
            'recordId': recordId,
            'drugs': <String>[],
          };
        }
        grouped[recordId]!['drugs'].add(item['drug_name']); // ✅ đúng key
      }

      return grouped.values.toList();
    } else {
      throw Exception('Lỗi khi tải đơn thuốc: ${response.statusCode}');
    }
  }

  /// Lấy chi tiết đơn thuốc theo ID đơn thuốc
  static Future<List<Map<String, dynamic>>> getPrescriptionDetails(
    int recordId,
  ) async {
    final headers = await _buildHeaders();
    final url = Uri.parse('$baseUrl/prescriptions/$recordId');

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      return data
          .map<Map<String, dynamic>>(
            (item) => {
              'detail_id': item['detail_id'],
              'drug_name': item['drug_name'],
              'drug_unit': item['drug_unit'],
              'concentration': item['concentration'],
              'prescribed_unit': item['prescribed_unit'],
              'quantity': item['quantity'],
              'time_of_day': item['time_of_day'],
              'meal_timing': item['meal_timing'],
            },
          )
          .toList();
    } else {
      throw Exception('Lỗi khi tải chi tiết đơn thuốc: ${response.statusCode}');
    }
  }
}
