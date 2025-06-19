import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:teleapp/services/medical_record_service.dart';
import 'package:teleapp/utils/auth_storage.dart';
import 'package:intl/intl.dart';

class DermatologyFormScreen extends StatefulWidget {
  const DermatologyFormScreen({super.key});

  @override
  State<DermatologyFormScreen> createState() => _DermatologyFormScreenState();
}

class _DermatologyFormScreenState extends State<DermatologyFormScreen> {
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
      final symptoms = formData?['symptoms'] ?? '';
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
          final path = '${dir.path}/form_dermatology_${DateTime.now().millisecondsSinceEpoch}.png';
          await File(path).writeAsBytes(image);
          await MedicalRecordService.uploadDiagnosisScreenshot(recordId, _screenshotController);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Đã gửi khai báo da liễu thành công!")),
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
        isActive: _currentStep == 0,
        content: Column(
          children: [
            FormBuilderTextField(
              name: 'symptoms',
              decoration: const InputDecoration(labelText: 'Triệu chứng chính'),
              maxLines: 3,
            ),
            FormBuilderRadioGroup(
              name: 'duration',
              decoration: const InputDecoration(labelText: 'Kéo dài bao lâu?'),
              options: ['Dưới 3 ngày', '3–7 ngày', '1–2 tuần', 'Hơn 2 tuần']
                  .map((e) => FormBuilderFieldOption(value: e))
                  .toList(),
            ),
            FormBuilderRadioGroup(
              name: 'progress',
              decoration: const InputDecoration(labelText: 'Tình trạng tiến triển'),
              options: ['Nặng dần', 'Đỡ dần', 'Ổn định', 'Tái phát nhiều lần']
                  .map((e) => FormBuilderFieldOption(value: e))
                  .toList(),
            ),
          ],
        ),
      ),
      Step(
        title: const Text(""),
        isActive: _currentStep == 1,
        content: Column(
          children: [
            FormBuilderRadioGroup(
              name: 'spreading',
              decoration: const InputDecoration(labelText: 'Có lan ra chỗ khác không?'),
              options: ['Không', 'Có']
                  .map((e) => FormBuilderFieldOption(value: e))
                  .toList(),
            ),
            FormBuilderTextField(
              name: 'spread_area',
              decoration: const InputDecoration(labelText: 'Vùng lan (nếu có)'),
            ),
            FormBuilderRadioGroup(
              name: 'had_before',
              decoration: const InputDecoration(labelText: 'Từng bị tương tự chưa?'),
              options: ['Chưa', 'Có']
                  .map((e) => FormBuilderFieldOption(value: e))
                  .toList(),
            ),
            FormBuilderTextField(
              name: 'last_occurrence',
              decoration: const InputDecoration(labelText: 'Lần gần nhất (nếu có)'),
            ),
            FormBuilderRadioGroup(
              name: 'allergy',
              decoration: const InputDecoration(labelText: 'Dị ứng'),
              options: ['Không rõ', 'Có']
                  .map((e) => FormBuilderFieldOption(value: e))
                  .toList(),
            ),
            FormBuilderTextField(
              name: 'allergy_detail',
              decoration: const InputDecoration(labelText: 'Chi tiết dị ứng (nếu có)'),
            ),
          ],
        ),
      ),
      Step(
        title: const Text(""),
        isActive: _currentStep == 2,
        content: Column(
          children: [
            FormBuilderTextField(
              name: 'medical_history',
              decoration: const InputDecoration(labelText: 'Tiền sử bệnh da liễu hoặc bệnh khác'),
              maxLines: 3,
            ),
            FormBuilderRadioGroup(
              name: 'taking_medicine',
              decoration: const InputDecoration(labelText: 'Đang dùng thuốc?'),
              options: ['Không', 'Có']
                  .map((e) => FormBuilderFieldOption(value: e))
                  .toList(),
            ),
            FormBuilderTextField(
              name: 'medicine_detail',
              decoration: const InputDecoration(labelText: 'Tên thuốc nếu biết'),
              maxLines: 2,
            ),
            FormBuilderRadioGroup(
              name: 'used_product',
              decoration: const InputDecoration(labelText: 'Đã từng khám/bôi thuốc chưa?'),
              options: ['Chưa', 'Rồi']
                  .map((e) => FormBuilderFieldOption(value: e))
                  .toList(),
            ),
            FormBuilderTextField(
              name: 'product_detail',
              decoration: const InputDecoration(labelText: 'Tên sản phẩm nếu biết'),
              maxLines: 2,
            ),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Khai Báo Da Liễu'),
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
