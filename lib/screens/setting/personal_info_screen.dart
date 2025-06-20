import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PersonalInfoScreen extends StatelessWidget {
  final Map<String, dynamic> info;

  const PersonalInfoScreen({super.key, required this.info});

  String formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '';
    final date = DateTime.tryParse(rawDate);
    return date != null ? DateFormat('dd/MM/yyyy').format(date) : rawDate;
  }

  Widget buildSection(String title, List<Map<String, String>> fields) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      shadowColor: Colors.teal.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade800,
              ),
            ),
            const SizedBox(height: 12),
            ...fields.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        item['label'] ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.teal.shade900,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        item['value'] ?? '',
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Thông tin cá nhân'),
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildSection('👤 Thông tin cơ bản', [
              {'label': 'Họ tên', 'value': info['FullName']},
              {'label': 'Ngày sinh', 'value': formatDate(info['DateOfBirth'])},
              {'label': 'Giới tính', 'value': info['Gender']},
              {'label': 'SĐT', 'value': info['Phone']},
              {'label': 'Địa chỉ', 'value': info['Address']},
              {'label': 'Nghề nghiệp', 'value': info['PatientJob']},
            ]),
            buildSection('🪪 Thông tin CCCD', [
              {'label': 'Số CCCD', 'value': info['CCCD']},
              {'label': 'Ngày cấp', 'value': formatDate(info['CCCDIssueDate'])},
              {'label': 'Nơi cấp', 'value': info['CCCDIssuePlace']},
              {'label': 'Ngày hết hạn', 'value': formatDate(info['CCCDExpiredDate'])},
              {'label': 'Dân tộc', 'value': info['Ethnicity']},
              {'label': 'Quốc tịch', 'value': info['Nationality']},
              {'label': 'Quê quán', 'value': info['Hometown']},
            ]),
            buildSection('👨‍👩‍👧 Người thân', [
              {'label': 'Tên người thân', 'value': info['RelativeName']},
              {'label': 'Quan hệ', 'value': info['Relationship']},
              {'label': 'SĐT người thân', 'value': info['RelativePhone']},
              {'label': 'Nghề nghiệp', 'value': info['RelativeJob']},
            ]),
          ],
        ),
      ),
    );
  }
}
