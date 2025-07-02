class PrescriptionDetail {
  final int detailId;
  final String drugName;
  final String drugUnit;
  final String concentration;
  final String prescribedUnit;
  final int quantity;
  final String timeOfDay;
  final String mealTiming;

  PrescriptionDetail({
    required this.detailId,
    required this.drugName,
    required this.drugUnit,
    required this.concentration,
    required this.prescribedUnit,
    required this.quantity,
    required this.timeOfDay,
    required this.mealTiming,
  });

  factory PrescriptionDetail.fromJson(Map<String, dynamic> json) {
    return PrescriptionDetail(
      detailId: json['detail_id'],
      drugName: json['drug_name'],
      drugUnit: json['drug_unit'],
      concentration: json['concentration'],
      prescribedUnit: json['prescribed_unit'],
      quantity: json['quantity'],
      timeOfDay: json['time_of_day'],
      mealTiming: json['meal_timing'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'detail_id': detailId,
      'drug_name': drugName,
      'drug_unit': drugUnit,
      'concentration': concentration,
      'prescribed_unit': prescribedUnit,
      'quantity': quantity,
      'time_of_day': timeOfDay,
      'meal_timing': mealTiming,
    };
  }
}
