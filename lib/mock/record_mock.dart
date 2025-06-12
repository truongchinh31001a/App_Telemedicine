final mockRecordDetail = {
  "record": {
    "RecordID": 2,
    "PatientID": 2,
    "CreatedDate": "2025-04-02T00:00:00.000Z",
    "Symptoms": "Đau sau mổ, sưng viêm",
    "DiagnosisCode": "1"
  },
  "vital": {
    "VitalSignsID": 2,
    "RecordID": 2,
    "Pulse": 85,
    "Temperature": 37.2,
    "RespirationRate": 18,
    "SpO2": 97,
    "Weight": 65,
    "Height": 165,
    "BMI": 23.9,
    "BSA": 1.75,
    "BloodPressureMin": 85,
    "BloodPressureMax": 130,
    "MeasuredBy": 7,
    "MeasuredAt": "2025-04-02T08:45:00.000Z",
    "Note": "Huyết áp hơi cao"
  },
  "prescriptions": [
    {
      "DetailID": 4,
      "DrugName": "Cefuroxim 500mg",
      "PrescribedUnit": "Viên",
      "Quantity": 2,
      "TimeOfDay": "Tối",
      "MealTiming": "Trước ăn"
    },
    {
      "DetailID": 5,
      "DrugName": "Diclofenac 50mg",
      "PrescribedUnit": "Viên",
      "Quantity": 2,
      "TimeOfDay": "Sáng",
      "MealTiming": "Sau ăn 30p"
    },
    {
      "DetailID": 6,
      "DrugName": "Povidon Iod 10%",
      "PrescribedUnit": "Chai",
      "Quantity": 1,
      "TimeOfDay": "Tối",
      "MealTiming": null
    }
  ],
  "labTests": [
    {
      "LabTestID": 1,
      "RecordID": 2,
      "TestType": "Xét nghiệm máu",
      "Result": "Các chỉ số trong giới hạn bình thường",
      "FilePath": "/files/lab/rid1.pdf"
    }
  ],
  "imagingTests": [
    {
      "ImagingTestID": 2,
      "RecordID": 3,
      "TestType": "Chụp X-quang",
      "Result": "Không phát hiện tổn thương",
      "FilePath": "/files/imaging/rid3.jpg"
    }
  ]
};
