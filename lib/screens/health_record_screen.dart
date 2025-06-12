import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teleapp/screens/record_detail_screen.dart';
import 'package:teleapp/services/medical_record_service.dart';

class HealthRecordScreen extends StatefulWidget {
  const HealthRecordScreen({super.key});

  @override
  State<HealthRecordScreen> createState() => _HealthRecordScreenState();
}

class _HealthRecordScreenState extends State<HealthRecordScreen> {
  List<Map<String, dynamic>> records = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadRecords();
  }

  Future<void> loadRecords() async {
    try {
      final data = await MedicalRecordService.fetchBasicRecords();
      setState(() {
        records = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi tải hồ sơ: $e')));
    }
  }

  String formatDate(String isoDate) {
    final date = DateTime.tryParse(isoDate);
    if (date == null) return isoDate;
    return DateFormat('dd/MM/yyyy').format(date);
  }

  void _viewDetail(BuildContext context, int recordId) async {
    try {
      final allRecords = await MedicalRecordService.fetchFullRecords();
      final record = allRecords.firstWhere((r) => r["RecordID"] == recordId);

      final vital = await MedicalRecordService.fetchVitals(recordId);
      final prescriptions = await MedicalRecordService.fetchPrescriptions(
        recordId,
      );
      final labTests = await MedicalRecordService.fetchLabTests(recordId);
      final imagingTests = await MedicalRecordService.fetchImagingTests(
        recordId,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => RecordDetailScreen(
                record: record,
                vital: vital,
                prescriptions: prescriptions,
                labTests: labTests,
                imagingTests: imagingTests,
              ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi xem chi tiết: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Hồ sơ bệnh án'),
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final item = records[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    shadowColor: Colors.teal.shade100,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal.shade100,
                        child: const Icon(
                          Icons.folder_open,
                          color: Colors.teal,
                        ),
                      ),
                      title: Text(
                        'Ngày khám: ${formatDate(item["CreatedDate"])}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text('Bác sĩ: ${item["DoctorName"]}'),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.teal,
                      ),
                      onTap: () => _viewDetail(context, item["RecordID"]),
                    ),
                  );
                },
              ),
    );
  }
}
