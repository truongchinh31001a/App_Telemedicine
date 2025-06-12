import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class RecordDetailScreen extends StatelessWidget {
  final Map<String, dynamic> record;
  final Map<String, dynamic> vital;
  final List<Map<String, dynamic>> prescriptions;
  final List<Map<String, dynamic>> labTests;
  final List<Map<String, dynamic>> imagingTests;

  const RecordDetailScreen({
    super.key,
    required this.record,
    required this.vital,
    required this.prescriptions,
    required this.labTests,
    required this.imagingTests,
  });

  String _formatDate(String iso, {bool withTime = true}) {
    final date = DateTime.tryParse(iso);
    return date != null
        ? DateFormat(withTime ? 'dd/MM/yyyy HH:mm' : 'dd/MM/yyyy').format(date)
        : iso;
  }

  String getDiagnosisName(String code) {
    const mapping = {
      "0": "Tăng huyết áp",
      "1": "Đái tháo đường",
      "2": "Viêm phổi",
      "3": "Viêm dạ dày",
      "4": "Cảm cúm",
    };
    return mapping[code] ?? "Không rõ";
  }

  void _openFile(String path) async {
    final url = 'http://192.168.1.199:3000$path';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Không thể mở: $url');
    }
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(top: 16.0, bottom: 8),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.teal.shade800,
          ),
        ),
      );

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.teal.shade900,
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Chi tiết hồ sơ #${record["RecordID"]}'),
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Thông tin bệnh án'),
            Card(
              elevation: 2,
              shadowColor: Colors.teal.shade100,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (record["CreatedDate"] != null)
                      _infoRow("Ngày tạo", _formatDate(record["CreatedDate"], withTime: false)),
                    if (record["Symptoms"] != null)
                      _infoRow("Triệu chứng", record["Symptoms"]),
                    if (record["DiagnosisCode"] != null)
                      _infoRow("Chẩn đoán", getDiagnosisName(record["DiagnosisCode"].toString())),
                  ],
                ),
              ),
            ),

            _sectionTitle('Sinh hiệu'),
            Card(
              elevation: 2,
              shadowColor: Colors.teal.shade100,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 20,
                  runSpacing: 8,
                  children: [
                    if (vital["Temperature"] != null)
                      Text('🌡 Nhiệt độ: ${vital["Temperature"]}°C'),
                    if (vital["BloodPressureMax"] != null && vital["BloodPressureMin"] != null)
                      Text('💓 Huyết áp: ${vital["BloodPressureMax"]}/${vital["BloodPressureMin"]} mmHg'),
                    if (vital["Pulse"] != null)
                      Text('❤️ Mạch: ${vital["Pulse"]} bpm'),
                    if (vital["SpO2"] != null)
                      Text('🫁 SpO2: ${vital["SpO2"]}%'),
                    if (vital["BMI"] != null)
                      Text('📏 BMI: ${vital["BMI"]}'),
                    if (vital["Height"] != null)
                      Text('📐 Chiều cao: ${vital["Height"]} cm'),
                    if (vital["Weight"] != null)
                      Text('⚖️ Cân nặng: ${vital["Weight"]} kg'),
                    if (vital["Note"] != null && vital["Note"].toString().isNotEmpty)
                      Text('📝 Ghi chú: ${vital["Note"]}'),
                  ],
                ),
              ),
            ),

            if (prescriptions.isNotEmpty) _sectionTitle('Đơn thuốc'),
            ...prescriptions.map((d) => Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              color: Colors.teal.shade50,
              child: ListTile(
                leading: const Icon(Icons.medical_services, color: Colors.teal),
                title: Text(d["DrugName"] ?? "Không rõ"),
                subtitle: Text(
                  '${d["Quantity"] ?? "-"} ${d["PrescribedUnit"] ?? ""} - '
                  '${d["TimeOfDay"] ?? "Không rõ"} - '
                  '${d["MealTiming"] ?? "Không rõ"}',
                ),
              ),
            )),

            if (labTests.isNotEmpty) _sectionTitle('Xét nghiệm'),
            ...labTests.map((l) => Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.bloodtype, color: Colors.teal),
                title: Text(l["TestType"] ?? "Không rõ"),
                subtitle: Text('Kết quả: ${l["Result"] ?? "Chưa có"}'),
                trailing: const Icon(Icons.picture_as_pdf, color: Colors.teal),
                onTap: () {
                  if (l["FilePath"] != null) {
                    _openFile(l["FilePath"]);
                  }
                },
              ),
            )),

            if (imagingTests.isNotEmpty) _sectionTitle('Chẩn đoán hình ảnh'),
            ...imagingTests.map((i) => Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: Colors.teal),
                title: Text(i["TestType"] ?? "Không rõ"),
                subtitle: Text('Kết quả: ${i["Result"] ?? "Chưa có"}'),
                trailing: const Icon(Icons.image, color: Colors.teal),
                onTap: () {
                  if (i["FilePath"] != null) {
                    _openFile(i["FilePath"]);
                  }
                },
              ),
            )),
          ],
        ),
      ),
    );
  }
}
