import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:teleapp/services/medical_record_service.dart';
import 'package:teleapp/utils/auth_storage.dart';
import 'package:intl/intl.dart';

class SurgeryFollowupFormScreen extends StatefulWidget {
  const SurgeryFollowupFormScreen({super.key});

  @override
  State<SurgeryFollowupFormScreen> createState() =>
      _SurgeryFollowupFormScreenState();
}

class _SurgeryFollowupFormScreenState extends State<SurgeryFollowupFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final ScreenshotController _screenshotController = ScreenshotController();
  int _currentStep = 0;

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _submitForm();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final user = await AuthStorage.getUser();
      final patientId = user?['patientId'];
      final formData = _formKey.currentState?.value;
      final symptoms = formData?['wound_status'] ?? '';
      final createdDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final recordId = await MedicalRecordService.createMedicalRecord(
        patientId,
        createdDate,
        symptoms,
      );

      if (recordId != null) {
        final image = await _screenshotController.capture();
        if (image != null) {
          final dir = await getTemporaryDirectory();
          final path =
              '${dir.path}/form_surgery_${DateTime.now().millisecondsSinceEpoch}.png';
          await File(path).writeAsBytes(image);
          await MedicalRecordService.uploadDiagnosisScreenshot(
            recordId,
            _screenshotController,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Đã gửi khai báo hậu phẫu thành công!"),
            ),
          );
        }
      }
    } else {
      print("❌ Form không hợp lệ");
    }
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text(""),
        content: Column(
          children: [
            FormBuilderCheckboxGroup(
              name: 'surgery_type',
              options:
                  [
                    'Mổ trĩ',
                    'Mổ áp xe',
                    'Cắt u nhỏ / tiểu phẫu',
                    'Khác',
                  ].map((e) => FormBuilderFieldOption(value: e)).toList(),
            ),
            FormBuilderTextField(
              name: 'surgery_other',
              decoration: const InputDecoration(labelText: 'Nếu khác, ghi rõ'),
            ),
            FormBuilderDateTimePicker(
              name: 'surgery_date',
              inputType: InputType.date,
              decoration: const InputDecoration(
                labelText: 'Ngày thực hiện phẫu thuật',
              ),
              format: DateFormat('yyyy-MM-dd'),
            ),
            FormBuilderTextField(
              name: 'hospital',
              decoration: const InputDecoration(
                labelText: 'Cơ sở y tế thực hiện',
              ),
            ),
          ],
        ),
        isActive: _currentStep == 0,
      ),
      Step(
        title: const Text(""),
        content: Column(
          children: [
            FormBuilderTextField(
              name: 'wound_status',
              decoration: const InputDecoration(
                labelText: 'Tình trạng vết mổ (mô tả)',
              ),
              maxLines: 3,
            ),
            FormBuilderCheckboxGroup(
              name: 'symptoms',
              decoration: const InputDecoration(
                labelText: 'Dấu hiệu xuất hiện',
              ),
              options:
                  [
                    'Đau nhiều',
                    'Sưng đỏ',
                    'Chảy dịch vàng / xanh',
                    'Chảy máu',
                    'Mùi hôi',
                    'Sốt trên 38°C',
                    'Khác',
                  ].map((e) => FormBuilderFieldOption(value: e)).toList(),
            ),
            FormBuilderTextField(
              name: 'other_symptom',
              decoration: const InputDecoration(labelText: 'Khác (nếu có)'),
            ),
            FormBuilderRadioGroup(
              name: 'pain_level',
              options:
                  [
                    'Không đau',
                    'Đau nhẹ',
                    'Đau trung bình',
                    'Đau nhiều, ảnh hưởng sinh hoạt',
                  ].map((e) => FormBuilderFieldOption(value: e)).toList(),
            ),
          ],
        ),
        isActive: _currentStep == 1,
      ),
      Step(
        title: const Text(""),
        content: Column(
          children: [
            FormBuilderRadioGroup(
              name: 'using_medicine',
              decoration: const InputDecoration(labelText: 'Đang dùng thuốc?'),
              options:
                  [
                    'Không',
                    'Có',
                  ].map((e) => FormBuilderFieldOption(value: e)).toList(),
            ),
            FormBuilderTextField(
              name: 'medicine_detail',
              decoration: const InputDecoration(labelText: 'Tên thuốc nếu có'),
              maxLines: 2,
            ),
            FormBuilderRadioGroup(
              name: 'wound_care',
              decoration: const InputDecoration(
                labelText: 'Cách chăm sóc vết thương',
              ),
              options:
                  [
                    'Tự chăm sóc tại nhà',
                    'Có y tá / điều dưỡng hỗ trợ',
                    'Không chăm sóc thường xuyên',
                  ].map((e) => FormBuilderFieldOption(value: e)).toList(),
            ),
            FormBuilderTextField(
              name: 'comorbidities',
              decoration: const InputDecoration(labelText: 'Bệnh nền (nếu có)'),
              maxLines: 2,
            ),
          ],
        ),
        isActive: _currentStep == 2,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Khai Báo Hậu Phẫu'),
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: Screenshot(
        controller: _screenshotController,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FormBuilder(
            key: _formKey,
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(
                  context,
                ).colorScheme.copyWith(primary: Colors.teal),
                shadowColor: Colors.transparent, // ✅ Bỏ viền quanh Step
              ),
              child: Stepper(
                type: StepperType.horizontal,
                currentStep: _currentStep,
                onStepContinue: _nextStep,
                onStepCancel: _prevStep,
                controlsBuilder:
                    (context, details) => Padding(
                      padding: const EdgeInsets.only(
                        top: 25,
                      ), // ✅ Cách nút phía dưới
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween, // ✅ Căn sang 2 bên
                        children: [
                          if (_currentStep > 0)
                            TextButton(
                              onPressed: details.onStepCancel,
                              child: const Text('Quay lại'),
                            )
                          else
                            const SizedBox(), // giữ layout khi không có nút trái
                          ElevatedButton(
                            onPressed: details.onStepContinue,
                            child: Text(
                              _currentStep == 2 ? 'Gửi khai báo' : 'Tiếp tục',
                            ),
                          ),
                        ],
                      ),
                    ),
                steps: _buildSteps(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
