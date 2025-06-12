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
        final recordId = item['RecordID'];
        if (!grouped.containsKey(recordId)) {
          grouped[recordId] = {
            'date': item['StartDate'].split('T')[0],
            'doctor': 'BS. ${item['DoctorName']}',
            'recordId': recordId,
            'drugs': <String>[],
          };
        }
        grouped[recordId]!['drugs'].add(item['DrugName']);
      }

      return grouped.values.toList();
    } else {
      throw Exception('Lỗi khi tải đơn thuốc: ${response.statusCode}');
    }
  }

  /// Lấy chi tiết đơn thuốc theo recordId
  static Future<List<Map<String, dynamic>>> getPrescriptionDetails(
    int recordId,
  ) async {
    final headers = await _buildHeaders();
    final url = Uri.parse('$baseUrl/prescriptions/$recordId');

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Lỗi khi tải chi tiết đơn thuốc: ${response.statusCode}');
    }
  }
}
