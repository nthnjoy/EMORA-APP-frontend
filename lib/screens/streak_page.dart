import 'package:flutter/material.dart';

class StreakPage extends StatelessWidget {
  final List<Map<String, dynamic>> moods;

  const StreakPage({super.key, required this.moods});

  String _dayLabel(DateTime date) {
    const names = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
    return names[date.weekday % 7];
  }

  int _currentStreak() {
    var count = 0;
    for (var i = moods.length - 1; i >= 0; i--) {
      final entry = moods[i];
      final value = entry['count'] as int? ?? 0;
      if (value > 0) {
        count += 1;
      } else {
        break;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final streak = _currentStreak();
    final isActive = streak > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Streak'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isActive ? Colors.deepPurple : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Streak saat ini',
                      style: TextStyle(
                        color: isActive ? Colors.white70 : Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isActive ? '$streak Hari Berturut-turut' : 'Streak belum aktif',
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.black87,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isActive
                          ? 'Teruskan dengan mengisi mood atau cerita hari ini.'
                          : 'Masukkan mood atau cerita untuk memulai streak kamu.',
                      style: TextStyle(
                        color: isActive ? Colors.white70 : Colors.black54,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Riwayat 7 hari terakhir',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: moods.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final entry = moods[index];
                    final day = entry['date'] as DateTime;
                    final count = entry['count'] as int;
                    final active = count > 0;
                    return Container(
                      decoration: BoxDecoration(
                        color: active ? Colors.white : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: active ? Colors.deepPurple : Colors.grey.shade300,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: active ? Colors.deepPurple : Colors.grey.shade300,
                            child: Text(
                              _dayLabel(day),
                              style: TextStyle(
                                color: active ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${day.day}/${day.month}/${day.year}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  active ? '$count input mood/cerita' : 'Belum ada input',
                                  style: TextStyle(
                                    color: active ? Colors.black87 : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            active ? Icons.check_circle : Icons.remove_circle_outline,
                            color: active ? Colors.deepPurple : Colors.grey,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringCapitalization on String {
  String capitalize() {
    if (isEmpty) return this;
    return substring(0, 1).toUpperCase() + substring(1);
  }
}
