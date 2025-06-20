import 'package:flutter/material.dart';
import 'package:teleapp/screens/change_password_screen.dart';
import 'package:teleapp/screens/personal_info_screen.dart';
import 'package:teleapp/services/user_service.dart';
import 'package:teleapp/utils/auth_storage.dart';
import 'login_screen.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  String? username;

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  Future<void> loadUserInfo() async {
    final user = await AuthStorage.getUser();
    setState(() {
      username = user?['username'] ?? 'Không rõ';
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = [
      {
        'icon': Icons.person,
        'title': 'Thông tin cá nhân',
        'onTap': (BuildContext context) async {
          try {
            final info = await UserService.fetchPersonalInfo();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PersonalInfoScreen(info: info)),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi tải thông tin cá nhân: $e')),
            );
          }
        },
      },
      {
        'icon': Icons.lock,
        'title': 'Đổi mật khẩu',
        'onTap': (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
          );
        },
      },
      {
        'icon': Icons.language,
        'title': 'Ngôn ngữ',
        'onTap': () => print('Ngôn ngữ'),
      },
      {
        'icon': Icons.logout,
        'title': 'Đăng xuất',
        'onTap': (BuildContext context) async {
          await AuthStorage.clear();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
            (route) => false,
          );
        },
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Cài đặt'),
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          // ✅ Phần avatar + tên người dùng
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              border: Border(bottom: BorderSide(color: Colors.teal.shade100)),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.teal,
                  child: Icon(Icons.person, size: 32, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  username ?? 'Đang tải...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade900,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: settings.length,
              separatorBuilder: (_, __) => Divider(color: Colors.grey.shade300),
              itemBuilder: (context, index) {
                final item = settings[index];
                return ListTile(
                  leading: Icon(item['icon'] as IconData, color: Colors.teal.shade700),
                  title: Text(
                    item['title'] as String,
                    style: TextStyle(color: Colors.black87),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    final handler = item['onTap'];
                    if (handler is Function) {
                      if (handler is Function(BuildContext)) {
                        handler(context);
                      } else {
                        handler();
                      }
                    }
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  tileColor: Colors.white,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
