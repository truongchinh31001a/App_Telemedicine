import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:teleapp/utils/auth_storage.dart';

class MedicalRecordService {
  static const String baseUrl = 'http://192.168.1.199:3000';

  static Future<List<Map<String, dynamic>>> fetchBasicRecords() async {
    final user = await AuthStorage.getUser();
    final token = await AuthStorage.getToken();
    final patientId = user?['patientId'];

    final response = await http.get(
      Uri.parse('$baseUrl/medical-records/records/$patientId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Lỗi khi lấy hồ sơ cơ bản');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchFullRecords() async {
    final user = await AuthStorage.getUser();
    final token = await AuthStorage.getToken();
    final patientId = user?['patientId'];

    final response = await http.get(
      Uri.parse('$baseUrl/medical-records/patient/$patientId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Lỗi khi lấy hồ sơ chi tiết');
    }
  }

  static Future<Map<String, dynamic>> fetchVitals(int recordId) async {
    final token = await AuthStorage.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/medical-records/vitals/$recordId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data.isNotEmpty ? Map<String, dynamic>.from(data[0]) : {};
    } else {
      throw Exception('Lỗi khi lấy dấu hiệu sinh tồn');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchPrescriptions(int recordId) async {
    final token = await AuthStorage.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/prescriptions/$recordId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Lỗi khi lấy đơn thuốc');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchLabTests(int recordId) async {
    final token = await AuthStorage.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/lab-tests/$recordId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Lỗi khi lấy xét nghiệm');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchImagingTests(int recordId) async {
    final token = await AuthStorage.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/imaging-tests/$recordId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Lỗi khi lấy chẩn đoán hình ảnh');
    }
  }
}
