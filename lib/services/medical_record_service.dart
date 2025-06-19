import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:teleapp/utils/auth_storage.dart';

class MedicalRecordService {
  static const String _baseUrl = 'http://192.168.1.199:3000';
  static const String _uploadUrl = 'http://192.168.1.199:3012';

  static Future<List<Map<String, dynamic>>> fetchBasicRecords() async {
    final user = await AuthStorage.getUser();
    final token = await AuthStorage.getToken();
    final patientId = user?['patientId'];

    final response = await http.get(
      Uri.parse('$_baseUrl/medical-records/records/$patientId'),
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
      Uri.parse('$_baseUrl/medical-records/patient/$patientId'),
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
      Uri.parse('$_baseUrl/medical-records/patient/vitals/$recordId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data.isNotEmpty ? Map<String, dynamic>.from(data[0]) : {};
    } else {
      throw Exception('Lỗi khi lấy dấu hiệu sinh tồn');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchPrescriptions(
    int recordId,
  ) async {
    final token = await AuthStorage.getToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/prescriptions/$recordId'),
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
      Uri.parse('$_baseUrl/lab-tests/$recordId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Lỗi khi lấy xét nghiệm');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchImagingTests(
    int recordId,
  ) async {
    final token = await AuthStorage.getToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/imaging-tests/$recordId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Lỗi khi lấy chẩn đoán hình ảnh');
    }
  }

  static Future<int?> createMedicalRecord(
    int patientId,
    String createdDate,
    String symptoms,
  ) async {
    final uri = Uri.parse('$_baseUrl/medical-records/');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'PatientID': patientId,
        'CreatedDate': createdDate,
        'Symptoms': symptoms,
        'DiagnosisCode': null,
      }),
    );

    if (response.statusCode == 201) {
      return int.tryParse(response.body);
    } else {
      print('Error creating record: ${response.statusCode} ${response.body}');
      return null;
    }
  }

  static Future<void> uploadDiagnosisScreenshot(
    int recordId,
    ScreenshotController controller,
  ) async {
    final image = await controller.capture();
    if (image == null) return;

    final tempDir = await getTemporaryDirectory();
    final file = await File(
      '${tempDir.path}/form_screenshot.png',
    ).writeAsBytes(image);

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_uploadUrl/upload/diagnosis/record/$recordId'),
    );
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    if (response.statusCode != 200 && response.statusCode != 201) {
      print('Upload diagnosis screenshot failed: ${response.statusCode}');
    }
  }

  static Future<void> uploadSymptomImages(
    int recordId,
    List<File> images,
  ) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_uploadUrl/upload/symptoms/record/$recordId'),
    );
    for (var img in images) {
      request.files.add(await http.MultipartFile.fromPath('file', img.path));
    }

    final response = await request.send();
    if (response.statusCode != 200 && response.statusCode != 201) {
      print('Upload symptom images failed: ${response.statusCode}');
    }
  }
}
