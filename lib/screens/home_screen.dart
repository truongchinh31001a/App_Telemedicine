import 'package:flutter/material.dart';
import 'package:teleapp/screens/appointments_screen.dart';
import 'package:teleapp/screens/book_screen.dart';
import 'package:teleapp/screens/medical_history_screen.dart';
import 'package:teleapp/screens/prescriptions_screen.dart';
import 'health_record_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(viewportFraction: 1.0);
  int _currentPage = 0;

  final List<Map<String, dynamic>> _featureItems = [
    {'icon': Icons.calendar_today, 'label': 'Đặt lịch hẹn', 'route': 'Đặt lịch hẹn bác sĩ'},
    {'icon': Icons.event_note, 'label': 'Lịch khám', 'route': 'Lịch khám'},
    {'icon': Icons.folder_shared, 'label': 'Hồ sơ', 'route': 'Hồ sơ sức khỏe'},
    {'icon': Icons.local_pharmacy, 'label': 'Đơn thuốc', 'route': 'Đơn thuốc của tôi'},
    {'icon': Icons.history, 'label': 'Bệnh sử', 'route': 'Bệnh sử'},
  ];

  void _navigate(BuildContext context, String routeName) {
    if (routeName == 'Hồ sơ sức khỏe') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => HealthRecordScreen()));
    } else if (routeName == 'Đơn thuốc của tôi') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => PrescriptionsScreen()));
    } else if (routeName == 'Lịch khám') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => AppointmentsScreen()));
    } else if (routeName == 'Đặt lịch hẹn bác sĩ') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => BookScreen()));
    } else if (routeName == 'Bệnh sử') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => MedicalHistoryScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đi tới: $routeName')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (_featureItems.length / 4).ceil();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Trang chủ'),
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/hospital.jpg',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 310,
              child: PageView.builder(
                controller: _pageController,
                itemCount: totalPages,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, pageIndex) {
                  final start = pageIndex * 4;
                  final end = (start + 4).clamp(0, _featureItems.length);
                  final pageItems = _featureItems.sublist(start, end);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.3,
                      physics: const NeverScrollableScrollPhysics(),
                      children: pageItems
                          .map((item) => _buildFeatureButton(
                                context,
                                item['icon'],
                                item['label'],
                                item['route'],
                              ))
                          .toList(),
                    ),
                  );
                },
              ),
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(totalPages, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index ? Colors.teal : Colors.grey.shade300,
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 10),
            _buildSectionTitle('👨‍⚕️ Bác sĩ nổi bật'),
            _buildHorizontalList(['BS. Trần Văn A', 'BS. Nguyễn Thị B', 'BS. Lê Văn C']),
            _buildSectionTitle('🏥 Chuyên khoa'),
            _buildHorizontalList(['Nội tổng quát', 'Tim mạch', 'Tiêu hoá', 'Nhi khoa']),
            _buildSectionTitle('📰 Tin tức y tế'),
            _buildNewsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureButton(BuildContext context, IconData icon, String label, String routeName) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightBlue.shade50,
        foregroundColor: Colors.teal.shade800,
        padding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      onPressed: () => _navigate(context, routeName),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal.shade700),
      ),
    );
  }

  Widget _buildHorizontalList(List<String> items) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return Container(
            width: 140,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.teal.shade100.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                items[index],
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.teal.shade900),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNewsList() {
    final news = [
      'Cách phòng tránh sốt xuất huyết',
      'Lịch tiêm chủng mới nhất 2025',
      'Thực phẩm tốt cho người tiểu đường',
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: news.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(news[index]),
          leading: Icon(Icons.article_outlined, color: Colors.teal.shade700),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xem bài viết: ${news[index]}')));
          },
        );
      },
    );
  }
}
