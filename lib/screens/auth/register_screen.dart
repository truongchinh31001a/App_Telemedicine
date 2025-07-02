import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:teleapp/screens/capture_image/capture_image_screen.dart';
import 'package:teleapp/screens/auth/login_screen.dart';
import 'package:teleapp/services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _currentStep = 0;
  final _formKeys = List.generate(5, (_) => GlobalKey<FormState>());

  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  String _gender = 'Nam';
  final _phoneController = TextEditingController();

  final _addressController = TextEditingController();
  final _hometownController = TextEditingController();
  final _ethnicityController = TextEditingController();
  final _nationalityController = TextEditingController();

  final _cccdController = TextEditingController();
  final _cccdIssueDateController = TextEditingController();
  final _cccdIssuePlaceController = TextEditingController();
  final _cccdExpiredDateController = TextEditingController();
  XFile? _cccdFront;
  XFile? _cccdBack;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType type = TextInputType.text,
      String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      validator: validator ??
          (value) => value == null || value.isEmpty
              ? 'Vui lòng nhập $label'
              : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.teal.shade800),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
        ),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDatePickerField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          controller.text = DateFormat('yyyy-MM-dd').format(picked);
        }
      },
      validator: (value) =>
          value == null || value.isEmpty ? 'Vui lòng chọn $label' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.teal.shade800),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
        ),
        border: const OutlineInputBorder(),
        suffixIcon: Icon(Icons.calendar_today, color: Colors.teal.shade700),
      ),
    );
  }

  Future<void> _pickImage(bool isFront) async {
    final picked = await Navigator.push<XFile?>(
      context,
      MaterialPageRoute(builder: (_) => const CaptureImageScreen()),
    );
    if (picked != null) {
      setState(() => isFront ? _cccdFront = picked : _cccdBack = picked);
    }
  }

  void _nextStep() {
    if (_formKeys[_currentStep].currentState!.validate()) {
      if (_currentStep == 3) {
        if (_cccdFront == null || _cccdBack == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vui lòng chụp đầy đủ cả 2 mặt CCCD.')),
          );
          return;
        }
        _showConfirmModal();
      } else {
        setState(() => _currentStep++);
      }
    }
  }

  void _backStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  void _showConfirmModal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đăng ký'),
        content: const Text('Bạn có chắc muốn hoàn tất đăng ký với thông tin đã nhập?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Huỷ')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submit();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final data = {
      'Username': _usernameController.text,
      'Password': _passwordController.text,
      'Email': _emailController.text,
      'FullName': _nameController.text,
      'DateOfBirth': _dobController.text,
      'Phone': _phoneController.text,
      'Address': _addressController.text,
      'Hometown': _hometownController.text,
      'Gender': _gender,
      'CCCD': _cccdController.text,
      'CCCDIssueDate': _cccdIssueDateController.text,
      'CCCDIssuePlace': _cccdIssuePlaceController.text,
      'CCCDExpiredDate': _cccdExpiredDateController.text,
      'Ethnicity': _ethnicityController.text,
      'Nationality': _nationalityController.text,
      'CCCDFront': _cccdFront?.path,
      'CCCDBack': _cccdBack?.path,
    };

    try {
      final res = await ApiService.register(data);
      if (res.statusCode == 200 || res.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 Đăng ký thành công.')),
        );
        await Future.delayed(const Duration(seconds: 1));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        final message = jsonDecode(res.body)['message'] ?? 'Đăng ký thất bại';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ $message')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Lỗi kết nối: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      _buildStep1(),
      _buildStep2(),
      _buildStep3(),
      _buildStep4(),
      _buildStep5(),
    ];
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Đăng ký tài khoản'),
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(child: steps[_currentStep]),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  TextButton(onPressed: _backStep, child: const Text('Quay lại')),
                ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade600,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(_currentStep == 4 ? 'Hoàn tất' : 'Tiếp theo'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() => Form(
    key: _formKeys[0],
    child: Column(
      children: [
        _buildTextField(
          'Email',
          _emailController,
          type: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Vui lòng nhập Email';
            if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
              return 'Email không hợp lệ';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        _buildTextField(
          'Tên đăng nhập',
          _usernameController,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Vui lòng nhập tên đăng nhập';
            if (value.length < 4) return 'Tên đăng nhập phải từ 4 ký tự';
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
            if (value.length < 6) return 'Mật khẩu phải từ 6 ký tự';
            return null;
          },
          decoration: InputDecoration(
            labelText: 'Mật khẩu',
            labelStyle: TextStyle(color: Colors.teal.shade800),
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, color: Colors.teal.shade700),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          validator: (value) => value != _passwordController.text ? 'Mật khẩu không khớp' : null,
          decoration: InputDecoration(
            labelText: 'Xác nhận mật khẩu',
            labelStyle: TextStyle(color: Colors.teal.shade800),
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off, color: Colors.teal.shade700),
              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildStep2() => Form(
    key: _formKeys[1],
    child: Column(
      children: [
        _buildTextField('Họ và tên', _nameController),
        const SizedBox(height: 12),
        _buildDatePickerField('Ngày sinh', _dobController),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _gender,
          onChanged: (val) => setState(() => _gender = val!),
          items: ['Nam', 'Nữ', 'Khác']
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
          decoration: InputDecoration(
            labelText: 'Giới tính',
            labelStyle: TextStyle(color: Colors.teal.shade800),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
            ),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          'Số điện thoại',
          _phoneController,
          type: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Vui lòng nhập số điện thoại';
            if (!RegExp(r'^0[0-9]{9}$').hasMatch(value)) {
              return 'Số điện thoại không hợp lệ';
            }
            return null;
          },
        ),
      ],
    ),
  );

  Widget _buildStep3() => Form(
    key: _formKeys[2],
    child: Column(
      children: [
        _buildTextField('Địa chỉ', _addressController),
        const SizedBox(height: 12),
        _buildTextField('Quê quán', _hometownController),
        const SizedBox(height: 12),
        _buildTextField('Dân tộc', _ethnicityController),
        const SizedBox(height: 12),
        _buildTextField('Quốc tịch', _nationalityController),
      ],
    ),
  );

  Widget _buildStep4() => Form(
    key: _formKeys[3],
    child: Column(
      children: [
        _buildTextField(
          'Số CCCD',
          _cccdController,
          type: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Vui lòng nhập số CCCD';
            if (!RegExp(r'^\d{9,12}$').hasMatch(value)) {
              return 'Số CCCD không hợp lệ';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        _buildDatePickerField('Ngày cấp CCCD', _cccdIssueDateController),
        const SizedBox(height: 12),
        _buildTextField('Nơi cấp CCCD', _cccdIssuePlaceController),
        const SizedBox(height: 12),
        _buildDatePickerField('Ngày hết hạn CCCD', _cccdExpiredDateController),
        const SizedBox(height: 12),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => _pickImage(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ảnh CCCD Mặt Trước'),
            ),
            const SizedBox(width: 10),
            if (_cccdFront != null) const Text('✅'),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => _pickImage(false),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ảnh CCCD Mặt Sau'),
            ),
            const SizedBox(width: 10),
            if (_cccdBack != null) const Text('✅'),
          ],
        ),
      ],
    ),
  );

  Widget _buildStep5() => Form(
    key: _formKeys[4],
    child: const Center(
      child: Text(
        'Xác nhận lại thông tin và nhấn Hoàn tất để đăng ký.',
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    ),
  );
}
