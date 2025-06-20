import 'package:flutter/material.dart';
import 'package:teleapp/services/appointment_service.dart';
import 'livekit_room_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  List<Map<String, dynamic>> appointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAppointments();
  }

  Future<void> loadAppointments() async {
    try {
      final data = await AppointmentService.fetchAppointmentsByPatient();
      setState(() {
        appointments = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải lịch hẹn: $e')),
      );
    }
  }

  String getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return '✅ Đã duyệt';
      case 'pending':
        return '🕓 Chờ duyệt';
      case 'canceled':
        return '❌ Đã hủy';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final confirmed = appointments
        .where((a) => a['Status']?.toLowerCase() == 'confirmed')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('📅 Lịch khám'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : confirmed.isEmpty
              ? const Center(child: Text('Không có lịch khám đã duyệt'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: confirmed.length,
                  itemBuilder: (context, index) {
                    final item = confirmed[index];
                    final doctor = item['StaffName'];
                    final patient = item['PatientName'];
                    final roomName = item['Room'];
                    final statusLabel = getStatusLabel(item['Status']);
                    final workDate = DateTime.parse(item['WorkDate']).toLocal();
                    final startTime = TimeOfDay.fromDateTime(
                      DateTime.parse(item['StartTime']),
                    );

                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('👨‍⚕️ Bác sĩ: $doctor',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text('👤 Bệnh nhân: $patient'),
                            Text('🏥 Phòng: $roomName'),
                            Text('📌 Trạng thái: $statusLabel'),
                            Text(
                              '📆 Ngày: ${workDate.day}/${workDate.month}/${workDate.year}',
                            ),
                            Text('⏰ Giờ: ${startTime.format(context)}'),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.video_call),
                                label: const Text('Tham gia khám'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => LiveKitRoomScreen(
                                        name: patient,
                                        room: roomName,
                                      ),
                                    ),
                                  );
                                },
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
