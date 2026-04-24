import 'package:flutter/material.dart';

class MusicPage extends StatelessWidget {
  const MusicPage({super.key});

  static const List<Map<String, String>> tracks = [
    {'title': 'Senja Tenang', 'artist': 'Emolens Relax'},
    {'title': 'Hening Pagi', 'artist': 'Rileks Studio'},
    {'title': 'Pelukan Angin', 'artist': 'Soul Calm'},
    {'title': 'Langit Biru', 'artist': 'Meditasi Malam'},
    {'title': 'Jejak Air', 'artist': 'Harmonika Suara'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Musik Relaksasi'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: tracks.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final track = tracks[index];
            return Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.music_note, color: Colors.deepPurple, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track['title']!,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          track['artist']!,
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.play_arrow, color: Colors.deepPurple),
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
