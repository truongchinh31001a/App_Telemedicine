import 'package:flutter/material.dart';
import 'package:teleapp/services/prescription_service.dart';
import 'package:teleapp/utils/auth_storage.dart';
import 'prescription_detail_screen.dart';

class PrescriptionsScreen extends StatefulWidget {
  const PrescriptionsScreen({super.key});

  @override
  State<PrescriptionsScreen> createState() => _PrescriptionsScreenState();
}

class _PrescriptionsScreenState extends State<PrescriptionsScreen> {
  List<Map<String, dynamic>> prescriptions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final user = await AuthStorage.getUser();

      final patientId = user?['patientId'];
      if (patientId == null) throw Exception('Không tìm thấy patientId');

      final data = await PrescriptionService.getPrescriptionsByPatient(
        patientId,
      );

      setState(() {
        prescriptions = data;
        isLoading = false;
      });
    } catch (e, stack) {
      setState(() => isLoading = false);
      print(stack);
    }
  }

  void _onViewDetail(BuildContext context, String date, int recordId) async {
    try {
      final details = await PrescriptionService.getPrescriptionDetails(
        recordId,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => PrescriptionDetailScreen(date: date, details: details),
        ),
      );
    } catch (e, stack) {
      print(stack);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Đơn thuốc của tôi'),
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: prescriptions.length,
                itemBuilder: (context, index) {
                  final item = prescriptions[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    shadowColor: Colors.teal.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🔹 Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    item['date'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                item['doctor'],
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.teal.shade900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // 🔹 Drugs
                          Text(
                            'Thuốc: ${(item['drugs'] as List).join(', ')}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),

                          // 🔹 Button
                          Align(
                            alignment: Alignment.centerRight,
                            child: OutlinedButton.icon(
                              onPressed:
                                  () => _onViewDetail(
                                    context,
                                    item['date'],
                                    item['recordId'],
                                  ),
                              icon: const Icon(Icons.description),
                              label: const Text('Chi tiết'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.teal.shade700,
                                side: BorderSide(color: Colors.teal.shade300),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
