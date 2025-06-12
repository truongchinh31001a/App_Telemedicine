import 'package:flutter/material.dart';
import 'login_screen.dart';

class VerifySmsScreen extends StatefulWidget {
  final String phoneNumber;

  const VerifySmsScreen({super.key, required this.phoneNumber});

  @override
  State<VerifySmsScreen> createState() => _VerifySmsScreenState();
}

class _VerifySmsScreenState extends State<VerifySmsScreen> {
  final _codeController = TextEditingController();
  String _mockCode = '123456';

  void _verifyCode() {
    if (_codeController.text.trim() == _mockCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xác minh thành công!')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mã xác nhận không đúng')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Xác minh số điện thoại'),
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Mã xác nhận đã gửi đến số:',
              style: TextStyle(fontSize: 16, color: Colors.teal.shade800),
            ),
            Text(
              widget.phoneNumber,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade900,
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Nhập mã xác nhận',
                labelStyle: TextStyle(color: Colors.teal.shade700),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
                ),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _verifyCode,
              icon: Icon(Icons.verified),
              label: Text('Xác minh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
