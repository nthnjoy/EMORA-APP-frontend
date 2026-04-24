import 'package:flutter/material.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  static const Map<String, String> recommendations = {
    'senang': 'Bernyanyi atau menari sebentar untuk menjaga energi positif.',
    'marah': 'Lakukan latihan peregangan atau jalan singkat untuk melepas ketegangan.',
    'sedih': 'Dengarkan musik relaksasi dan tulis hal yang kamu syukuri.',
    'takut': 'Coba tarik napas dalam-dalam sambil duduk tenang selama satu menit.',
    'biasa': 'Ambil waktu satu menit untuk fokus pada pernapasan dan bersyukur.',
    'terkejut': 'Saatkan satu menit untuk merenungi apa yang terjadi dan tenangkan diri.',
    'jijik': 'Bergerak ringan atau buat minuman hangat untuk menenangkan tubuh.',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aktivitas'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              const Text(
                'Rekomendasi aktivitas berdasarkan mood',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),
              ...recommendations.entries.map((entry) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.deepPurple.shade50,
                        child: Text(
                          entry.key[0].toUpperCase(),
                          style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key.capitalize(),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              entry.value,
                              style: const TextStyle(fontSize: 14, height: 1.6),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
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
