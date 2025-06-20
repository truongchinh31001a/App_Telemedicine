class PrescriptionRecord {
  final int recordId;
  final String date;
  final String doctor;
  final List<String> drugs;

  PrescriptionRecord({
    required this.recordId,
    required this.date,
    required this.doctor,
    required this.drugs,
  });
}
