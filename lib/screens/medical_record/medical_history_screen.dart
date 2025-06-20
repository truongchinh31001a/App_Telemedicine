import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teleapp/services/medical_history_service.dart';

class MedicalHistoryScreen extends StatefulWidget {
  const MedicalHistoryScreen({super.key});

  @override
  State<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen> {
  Map<String, dynamic>? historyData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMedicalHistory();
  }

  Future<void> loadMedicalHistory() async {
    try {
      final data = await MedicalHistoryService.fetchMedicalHistory();
      setState(() {
        historyData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
    }
  }

  String formatDate(String iso) {
    final date = DateTime.tryParse(iso);
    return date != null ? DateFormat('dd/MM/yyyy').format(date) : iso;
  }

  Widget buildSection(String title, List<dynamic> items, List<String> keys) {
    if (items.isEmpty) return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        ...items.map(
          (item) => Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(item[keys[0]]),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tình trạng: ${item[keys[1]]}'),
                  Text('Ngày phát hiện: ${formatDate(item[keys[2]])}'),
                  Text('Bác sĩ: ${item['DoctorName']}'),
                  Text('Ghi chú: ${item['Note']}'),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bệnh sử'),
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : historyData == null
              ? const Center(child: Text('Không có dữ liệu'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildSection(
                      'Bệnh mãn tính',
                      historyData!['chronicHistory'],
                      ['DiseaseName', 'Status', 'DetectedDate'],
                    ),
                    buildSection(
                      'Tiền sử gia đình',
                      historyData!['familyHistory'],
                      ['DiseaseName', 'Status', 'DetectedDate'],
                    ),
                    buildSection(
                      'Tiền sử dị ứng',
                      historyData!['allergyHistory'],
                      ['Substance', 'Reaction', 'DetectedDate'],
                    ),
                  ],
                ),
              ),
    );
  }
}
