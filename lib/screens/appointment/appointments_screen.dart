import 'package:flutter/material.dart';
import 'package:teleapp/models/appointment.dart';
import 'package:teleapp/services/appointment_service.dart';
import 'livekit_room_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  List<Appointment> appointments = [];
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
      case 'đã duyệt':
        return '✅ Đã duyệt';
      case 'chờ duyệt':
        return '🕓 Chờ duyệt';
      case 'đã hủy':
        return '❌ Đã hủy';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final confirmed = appointments
        .where((a) => a.status.toLowerCase() == 'đã duyệt')
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
                            Text('👨‍⚕️ Bác sĩ: ${item.doctorName}',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text('👤 Bệnh nhân: ${item.patientName}'),
                            Text('🏥 Phòng: ${item.room}'),
                            Text('📌 Trạng thái: ${getStatusLabel(item.status)}'),
                            Text(
                              '📆 Ngày: ${item.workDate.day}/${item.workDate.month}/${item.workDate.year}',
                            ),
                            Text('⏰ Giờ: ${item.startTime.format(context)}'),
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
                                        name: item.patientName,
                                        room: item.room,
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
