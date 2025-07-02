import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:teleapp/models/prescription/prescription_detail.dart';
import 'package:teleapp/models/prescription/prescription_record.dart';
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
  static Future<List<PrescriptionRecord>> getPrescriptionsByPatient(
    int patientId,
  ) async {
    final headers = await _buildHeaders();
    final url = Uri.parse('$baseUrl/prescriptions/patient/$patientId');

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final Map<int, PrescriptionRecord> grouped = {};

      for (var item in data) {
        final int recordId = item['record_id'];

        if (!grouped.containsKey(recordId)) {
          grouped[recordId] = PrescriptionRecord(
            recordId: recordId,
            date: item['start_date'],
            doctor: 'BS. ${item['doctor_name']}',
            drugs: [],
          );
        }

        grouped[recordId]!.drugs.add(item['drug_name']);
      }

      return grouped.values.toList();
    } else {
      throw Exception('Lỗi khi tải đơn thuốc: ${response.statusCode}');
    }
  }

  /// Lấy chi tiết đơn thuốc theo ID đơn thuốc
  static Future<List<PrescriptionDetail>> getPrescriptionDetails(
    int recordId,
  ) async {
    final headers = await _buildHeaders();
    final url = Uri.parse('$baseUrl/prescriptions/$recordId');

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => PrescriptionDetail.fromJson(item)).toList();
    } else {
      throw Exception('Lỗi khi tải chi tiết đơn thuốc: ${response.statusCode}');
    }
  }
}
