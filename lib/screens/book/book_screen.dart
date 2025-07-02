import 'package:flutter/material.dart';
import 'package:teleapp/screens/book/medical_examination_form/dermatology-form-screen.dart';
import 'package:teleapp/screens/book/medical_examination_form/gynecology-form-screen.dart';
import 'package:teleapp/screens/book/medical_examination_form/surgery-followup-form-screen.dart';

class BookScreen extends StatelessWidget {
  const BookScreen({super.key});

  void _onCardTap(BuildContext context, String title) {
    if (title == 'Da Liễu') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DermatologyFormScreen()),
      );
    } else if (title == 'Hậu Phẫu') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SurgeryFollowupFormScreen()),
      );
    } else if (title == 'Phụ Khoa') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const GynecologyFormScreen()),
      );
    }
  }

  Widget _buildSpecialtyCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color backgroundColor,
  }) {
    return InkWell(
      onTap: () => _onCardTap(context, title),
      borderRadius: BorderRadius.circular(16),
      splashColor: Colors.teal.withOpacity(0.1),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.teal.shade100,
              radius: 28,
              child: Icon(icon, size: 30, color: Colors.teal.shade800),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.teal),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đặt lịch khám'),
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView(
        children: [
          _buildSpecialtyCard(
            context,
            title: 'Da Liễu',
            icon: Icons.face_retouching_natural,
            backgroundColor: const Color(0xFFF0FDFB),
          ),
          _buildSpecialtyCard(
            context,
            title: 'Hậu Phẫu',
            icon: Icons.healing,
            backgroundColor: const Color(0xFFFFF8F2),
          ),
          _buildSpecialtyCard(
            context,
            title: 'Phụ Khoa',
            icon: Icons.pregnant_woman,
            backgroundColor: const Color(0xFFFFF0F6),
          ),
        ],
      ),
    );
  }
}
