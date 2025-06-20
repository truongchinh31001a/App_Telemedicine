import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:teleapp/services/medical_record_service.dart';
import 'package:teleapp/utils/auth_storage.dart';
import 'package:intl/intl.dart';

class GynecologyFormScreen extends StatefulWidget {
  const GynecologyFormScreen({super.key});

  @override
  State<GynecologyFormScreen> createState() => _GynecologyFormScreenState();
}

class _GynecologyFormScreenState extends State<GynecologyFormScreen> {
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
      final symptoms = formData?['symptoms']?.join(', ') ?? '';
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
              '${dir.path}/form_gynecology_${DateTime.now().millisecondsSinceEpoch}.png';
          await File(path).writeAsBytes(image);
          await MedicalRecordService.uploadDiagnosisScreenshot(
            recordId,
            _screenshotController,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Đã gửi khai báo phụ khoa thành công!"),
            ),
          );
        }
      }
    }
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text(""),
        content: Column(
          children: [
            FormBuilderCheckboxGroup(
              name: 'symptoms',
              options:
                  [
                    'Ngứa/rát',
                    'Đau bụng dưới',
                    'Rối loạn kinh nguyệt',
                    'Tiểu buốt/rắt',
                    'Khác',
                  ].map((e) => FormBuilderFieldOption(value: e)).toList(),
            ),
            FormBuilderTextField(
              name: 'other_symptom',
              decoration: const InputDecoration(labelText: 'Khác (nếu có)'),
            ),
            FormBuilderRadioGroup(
              name: 'duration',
              decoration: const InputDecoration(labelText: 'Kéo dài bao lâu?'),
              options:
                  [
                    'Dưới 3 ngày',
                    '3–7 ngày',
                    'Trên 1 tuần',
                    'Trên 1 tháng',
                  ].map((e) => FormBuilderFieldOption(value: e)).toList(),
            ),
          ],
        ),
        isActive: _currentStep == 0,
      ),
      Step(
        title: const Text(""),
        content: Column(
          children: [
            FormBuilderCheckboxGroup(
              name: 'discharge',
              decoration: const InputDecoration(labelText: 'Tính chất khí hư'),
              options:
                  [
                    'Trong suốt',
                    'Đục trắng',
                    'Vàng/xanh',
                    'Có mùi hôi',
                    'Có lẫn máu',
                  ].map((e) => FormBuilderFieldOption(value: e)).toList(),
            ),
            FormBuilderDateTimePicker(
              name: 'last_period',
              inputType: InputType.date,
              decoration: const InputDecoration(labelText: 'Kinh gần nhất'),
              format: DateFormat('yyyy-MM-dd'),
            ),
            FormBuilderRadioGroup(
              name: 'cycle_regular',
              decoration: const InputDecoration(
                labelText: 'Chu kỳ có đều không?',
              ),
              options:
                  [
                    'Có',
                    'Không',
                  ].map((e) => FormBuilderFieldOption(value: e)).toList(),
            ),
            FormBuilderRadioGroup(
              name: 'pregnant',
              decoration: const InputDecoration(labelText: 'Nghi ngờ có thai?'),
              options:
                  [
                    'Có',
                    'Không',
                  ].map((e) => FormBuilderFieldOption(value: e)).toList(),
            ),
            FormBuilderRadioGroup(
              name: 'contraceptive_use',
              decoration: const InputDecoration(
                labelText: 'Có dùng tránh thai?',
              ),
              options:
                  [
                    'Có',
                    'Không',
                  ].map((e) => FormBuilderFieldOption(value: e)).toList(),
            ),
            FormBuilderTextField(
              name: 'contraceptive_detail',
              decoration: const InputDecoration(
                labelText: 'Phương pháp tránh thai (nếu có)',
              ),
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
              name: 'recent_exam',
              decoration: const InputDecoration(
                labelText: 'Khám phụ khoa gần đây?',
              ),
              options:
                  [
                    'Có',
                    'Chưa',
                  ].map((e) => FormBuilderFieldOption(value: e)).toList(),
            ),
            FormBuilderDateTimePicker(
              name: 'recent_exam_date',
              inputType: InputType.date,
              decoration: const InputDecoration(
                labelText: 'Ngày khám gần nhất',
              ),
              format: DateFormat('yyyy-MM-dd'),
            ),
            FormBuilderRadioGroup(
              name: 'gynecology_history',
              decoration: const InputDecoration(
                labelText: 'Tiền sử bệnh phụ khoa?',
              ),
              options:
                  [
                    'Có',
                    'Không',
                  ].map((e) => FormBuilderFieldOption(value: e)).toList(),
            ),
            FormBuilderTextField(
              name: 'gynecology_detail',
              decoration: const InputDecoration(labelText: 'Chi tiết nếu có'),
              maxLines: 2,
            ),
            FormBuilderRadioGroup(
              name: 'test_done',
              decoration: const InputDecoration(
                labelText: 'Đã từng xét nghiệm phụ khoa?',
              ),
              options:
                  [
                    'Có',
                    'Không',
                  ].map((e) => FormBuilderFieldOption(value: e)).toList(),
            ),
            FormBuilderTextField(
              name: 'test_detail',
              decoration: const InputDecoration(labelText: 'Chi tiết nếu có'),
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
        title: Text('Khai Báo Phụ Khoa'),
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
