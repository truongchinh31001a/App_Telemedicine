import 'package:flutter/material.dart';

class PrescriptionDetailScreen extends StatelessWidget {
  final String date;
  final List<Map<String, dynamic>> details;

  const PrescriptionDetailScreen({
    super.key,
    required this.date,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Chi tiết đơn thuốc'),
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: details.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = details[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            shadowColor: Colors.teal.shade100,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['drug_name'] ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('💊 Hàm lượng: ${item['concentration'] ?? ''}'),
                  Text(
                    '📦 Số lượng: ${item['quantity']} ${item['prescribed_unit']}',
                  ),
                  Text('⏱ Thời điểm uống: ${item['time_of_day']}'),
                  Text('🍽 Trước/Sau ăn: ${item['meal_timing'] ?? "Không rõ"}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
