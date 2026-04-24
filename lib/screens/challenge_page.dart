import 'package:flutter/material.dart';

class ChallengePage extends StatelessWidget {
  const ChallengePage({super.key});

  static const List<String> challenges = [
    'Lakukan push up kurang dari satu menit',
    'Tulis selama satu menit tentang hari ini',
    'Melamun selama satu menit tanpa gangguan',
    'Berjalan santai selama beberapa menit',
    'Tarik napas dalam dan hembuskan perlahan selama satu menit',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tantangan'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: challenges.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
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
                    backgroundColor: Colors.deepPurple.shade100,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      challenges[index],
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
