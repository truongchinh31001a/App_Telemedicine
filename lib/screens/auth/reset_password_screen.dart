import 'package:flutter/material.dart';
import 'package:teleapp/services/auth_service.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String otpSessionId;

  const ResetPasswordScreen({super.key, required this.otpSessionId});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;

  void _submit() async {
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (password.length < 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Mật khẩu phải từ 6 ký tự')));
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xác nhận mật khẩu không khớp')),
      );
      return;
    }

    try {
      await AuthService.resetPassword(widget.otpSessionId, password);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 Đặt lại mật khẩu thành công')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
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
        title: const Text('Tạo mật khẩu mới'),
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _passwordController,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'Mật khẩu mới',
                labelStyle: TextStyle(color: Colors.teal.shade800),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
                ),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.teal.shade700,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmController,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'Xác nhận mật khẩu',
                labelStyle: TextStyle(color: Colors.teal.shade800),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.lock_open),
              label: const Text('Xác nhận'),
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
