import 'package:flutter/material.dart';

class Appointment {
  final int appointmentId;
  final String doctorName;
  final String patientName;
  final String room;
  final String status;
  final DateTime workDate;
  final TimeOfDay startTime;

  Appointment({
    required this.appointmentId,
    required this.doctorName,
    required this.patientName,
    required this.room,
    required this.status,
    required this.workDate,
    required this.startTime,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    final workDate = DateTime.parse(json['work_date']);
    final startDateTime = DateTime.parse('${json['work_date']} ${json['start_time']}');

    return Appointment(
      appointmentId: json['appointment_id'],
      doctorName: json['doctor_name'] ?? 'Không rõ',
      patientName: json['patient_name'] ?? 'Không rõ',
      room: json['room'] ?? 'Không rõ',
      status: json['status'],
      workDate: workDate,
      startTime: TimeOfDay.fromDateTime(startDateTime),
    );
  }
}
