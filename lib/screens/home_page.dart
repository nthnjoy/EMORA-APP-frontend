import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_page.dart';
import 'mood_page.dart';
import 'statistics_page.dart';
import 'mood_calender_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.currentUser;
    final userName = user?.email?.split('@')[0] ?? "User";

    final List<Map<String, dynamic>> emotions = [
      {'icon': '😊', 'label': 'senang', 'color': Colors.yellow[300]},
      {'icon': '😡', 'label': 'marah', 'color': Colors.red[200]},
      {'icon': '😢', 'label': 'sedih', 'color': Colors.blue[200]},
      {'icon': '😱', 'label': 'takut', 'color': Colors.purple[200]},
      {'icon': '😐', 'label': 'biasa', 'color': Colors.grey[300]},
      {'icon': '😲', 'label': 'kaget', 'color': Colors.orange[200]},
      {'icon': '🤢', 'label': 'jijik', 'color': Colors.green[200]},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFDCE8F4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.local_fire_department, color: Colors.purple),
            const SizedBox(width: 8),
            const Text(
              "IT DEL EMOLENS",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: Colors.purpleAccent,
                  borderRadius: BorderRadius.circular(8)),
              child: const Text(
                "5 Streak",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {},
            )
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bagaimana perasaanmu, $userName?",
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 8),
            const Text(
              "Laporan harian membantu kami untuk mendukung kesejahteraan mental Anda.",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: emotions.map((e) {
                  return GestureDetector(
                    onTap: () {
                      // langsung masuk ke MoodPage dengan mood terpilih
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MoodPage(
                            initialMood: e['label'],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: e['color'],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black26),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            e['icon'],
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            e['label'].toString().toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}