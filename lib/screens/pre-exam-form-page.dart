import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:teleapp/services/upload_service.dart';

class PreExamFormPage extends StatefulWidget {
  @override
  State<PreExamFormPage> createState() => _PreExamFormPageState();
}

class _PreExamFormPageState extends State<PreExamFormPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final ScreenshotController _screenshotController = ScreenshotController();
  Uint8List? _capturedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Khai Báo Trước Khám")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// ✅ Chụp phần Form, có nền trắng
            Screenshot(
              controller: _screenshotController,
              child: Container(
                color: Colors.white, // ✅ Nền trắng
                padding: const EdgeInsets.all(8),
                child: FormBuilder(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        "1. Thông tin người khám",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      FormBuilderTextField(
                        name: 'full_name',
                        decoration: const InputDecoration(
                          labelText: 'Họ và tên',
                        ),
                      ),
                      FormBuilderTextField(
                        name: 'age',
                        decoration: const InputDecoration(labelText: 'Tuổi'),
                        keyboardType: TextInputType.number,
                      ),
                      FormBuilderRadioGroup(
                        name: 'exam_for',
                        decoration: const InputDecoration(
                          labelText: 'Khám cho ai?',
                        ),
                        options:
                            ['Tôi', 'Người thân của tôi']
                                .map((e) => FormBuilderFieldOption(value: e))
                                .toList(),
                      ),
                      FormBuilderTextField(
                        name: 'relative_age',
                        decoration: const InputDecoration(
                          labelText: 'Tuổi người thân',
                        ),
                      ),
                      FormBuilderTextField(
                        name: 'relationship',
                        decoration: const InputDecoration(
                          labelText: 'Mối quan hệ',
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "2. Triệu chứng chính bạn đang gặp phải",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      FormBuilderTextField(
                        name: 'symptoms',
                        decoration: const InputDecoration(
                          labelText: 'Triệu chứng',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "3. Tình trạng kéo dài bao lâu?",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      FormBuilderRadioGroup(
                        name: 'duration',
                        options:
                            [
                                  'Dưới 3 ngày',
                                  '3–7 ngày',
                                  '1–2 tuần',
                                  'Hơn 2 tuần',
                                ]
                                .map((e) => FormBuilderFieldOption(value: e))
                                .toList(),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "4. Tình trạng tiến triển",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      FormBuilderRadioGroup(
                        name: 'progress',
                        options:
                            [
                                  'Nặng dần',
                                  'Đỡ dần',
                                  'Ổn định',
                                  'Tái phát nhiều lần',
                                ]
                                .map((e) => FormBuilderFieldOption(value: e))
                                .toList(),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "5. Có lan ra chỗ khác không?",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      FormBuilderRadioGroup(
                        name: 'spreading',
                        options:
                            ['Không', 'Có']
                                .map((e) => FormBuilderFieldOption(value: e))
                                .toList(),
                      ),
                      FormBuilderTextField(
                        name: 'spread_area',
                        decoration: const InputDecoration(
                          labelText: 'Vùng lan (nếu có)',
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "6. Từng bị tương tự chưa?",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      FormBuilderRadioGroup(
                        name: 'had_before',
                        options:
                            ['Chưa', 'Có']
                                .map((e) => FormBuilderFieldOption(value: e))
                                .toList(),
                      ),
                      FormBuilderTextField(
                        name: 'last_occurrence',
                        decoration: const InputDecoration(
                          labelText: 'Lần gần nhất (nếu có)',
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "7. Có dị ứng với gì không?",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      FormBuilderRadioGroup(
                        name: 'allergy',
                        options:
                            ['Không rõ', 'Có']
                                .map((e) => FormBuilderFieldOption(value: e))
                                .toList(),
                      ),
                      FormBuilderTextField(
                        name: 'allergy_detail',
                        decoration: const InputDecoration(
                          labelText: 'Chi tiết dị ứng (nếu có)',
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "8. Tiền sử bệnh da liễu hoặc bệnh khác",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      FormBuilderTextField(
                        name: 'medical_history',
                        decoration: const InputDecoration(
                          labelText: 'Tiền sử bệnh',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "9. Có đang dùng thuốc không?",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      FormBuilderRadioGroup(
                        name: 'taking_medicine',
                        options:
                            ['Không', 'Có']
                                .map((e) => FormBuilderFieldOption(value: e))
                                .toList(),
                      ),
                      FormBuilderTextField(
                        name: 'medicine_detail',
                        decoration: const InputDecoration(
                          labelText: 'Tên thuốc nếu biết',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "10. Đã từng khám/bôi thuốc chưa?",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      FormBuilderRadioGroup(
                        name: 'used_product',
                        options:
                            ['Chưa', 'Rồi']
                                .map((e) => FormBuilderFieldOption(value: e))
                                .toList(),
                      ),
                      FormBuilderTextField(
                        name: 'product_detail',
                        decoration: const InputDecoration(
                          labelText: 'Tên sản phẩm nếu biết',
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState?.saveAndValidate() ?? false) {
                  final formData = _formKey.currentState?.value;
                  print("✅ Dữ liệu đã nhập: $formData");

                  await Future.delayed(const Duration(milliseconds: 300));
                  final image = await _screenshotController.capture();
                  if (image != null) {
                    setState(() {
                      _capturedImage = image;
                    });

                    final dir = await getTemporaryDirectory();
                    final path =
                        '${dir.path}/form_khaibao_${DateTime.now().millisecondsSinceEpoch}.png';
                    await File(path).writeAsBytes(image);
                    print("📸 Ảnh đã lưu tại: $path");

                    await uploadFormImage(path);
                  } else {
                    print("❌ Không chụp được ảnh");
                  }
                } else {
                  print("❌ Form không hợp lệ");
                }
              },
              child: const Text("Xác nhận và lưu ảnh"),
            ),
            const SizedBox(height: 20),
            if (_capturedImage != null) ...[
              const Text(
                "Ảnh form đã chụp:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Image.memory(_capturedImage!),
            ],
          ],
        ),
      ),
    );
  }
}
