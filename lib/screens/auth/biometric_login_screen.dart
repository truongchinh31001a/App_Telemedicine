import 'package:flutter/material.dart';
import 'package:teleapp/services/biometric_service.dart';
import 'package:teleapp/utils/auth_storage.dart';
import '../main_screen.dart';
import 'login_screen.dart';

class BiometricLoginScreen extends StatefulWidget {
  const BiometricLoginScreen({super.key});

  @override
  State<BiometricLoginScreen> createState() => _BiometricLoginScreenState();
}

class _BiometricLoginScreenState extends State<BiometricLoginScreen> {
  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    final biometric = BiometricService();

    final available = await biometric.isAvailable();
    if (!available) {
      _showError('Thiết bị không hỗ trợ sinh trắc học');
      _redirectToLogin();
      return;
    }

    final success = await biometric.authenticate();
    if (success) {
      final token = await AuthStorage.getToken();
      if (token != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainScreen()),
        );
      } else {
        _showError('Không tìm thấy token');
        _redirectToLogin();
      }
    } else {
      _showError('Xác thực không thành công');
      _redirectToLogin();
    }
  }

  void _redirectToLogin() {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Đang xác thực sinh trắc học...'),
          ],
        ),
      ),
    );
  }
}
