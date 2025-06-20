import 'package:flutter/material.dart';
import 'package:teleapp/screens/reset_password_screen.dart';
import 'package:teleapp/services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  bool _codeSent = false;
  String? _otpSessionId;

  void _sendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập email hợp lệ')),
      );
      return;
    }

    try {
      final sessionId = await AuthService.sendOtp(email);
      setState(() {
        _codeSent = true;
        _otpSessionId = sessionId;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('📧 Mã xác nhận đã gửi tới $email')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ ${e.toString()}')));
    }
  }

  void _verifyCode() async {
    final inputCode = _codeController.text.trim();

    if (_otpSessionId == null || inputCode.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Thiếu mã hoặc session ID')));
      return;
    }

    try {
      await AuthService.verifyOtp(_otpSessionId!, inputCode);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('✅ Xác minh thành công')));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(otpSessionId: _otpSessionId!),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Xác minh email'),
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              enabled: !_codeSent,
              decoration: InputDecoration(
                labelText: 'Địa chỉ email',
                labelStyle: TextStyle(color: Colors.teal.shade800),
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            !_codeSent
                ? ElevatedButton.icon(
                  icon: const Icon(Icons.email),
                  label: const Text('Gửi mã xác nhận'),
                  onPressed: _sendCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade600,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                )
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _codeController,
                      decoration: InputDecoration(
                        labelText: 'Nhập mã xác nhận',
                        labelStyle: TextStyle(color: Colors.teal.shade800),
                        border: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.teal.shade700,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.verified_user),
                      label: const Text('Xác minh & Tiếp tục'),
                      onPressed: _verifyCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade600,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}
