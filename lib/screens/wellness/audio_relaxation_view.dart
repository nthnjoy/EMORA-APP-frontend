import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AudioRelaxationView extends StatefulWidget {
  const AudioRelaxationView({super.key});

  @override
  State<AudioRelaxationView> createState() => _AudioRelaxationViewState();
}

class _AudioRelaxationViewState extends State<AudioRelaxationView> {
  final List<Map<String, dynamic>> _sounds = [
    {'name': 'Hujan Rintik', 'icon': Icons.umbrella_rounded, 'color': Colors.blue},
    {'name': 'Suara Hutan', 'icon': Icons.forest_rounded, 'color': Colors.green},
    {'name': 'Ombak Pantai', 'icon': Icons.waves_rounded, 'color': Colors.lightBlue},
    {'name': 'Api Unggun', 'icon': Icons.local_fire_department_rounded, 'color': Colors.orange},
  ];
  int? _playingIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close_rounded, color: Colors.black87), onPressed: () => Navigator.pop(context)),
        title: Text('Audio Relaksasi', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: _sounds.length,
        itemBuilder: (context, index) {
          final s = _sounds[index];
          final isPlaying = _playingIndex == index;
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: s['color'].withOpacity(0.05), blurRadius: 10)],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: s['color'].withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                  child: Icon(s['icon'], color: s['color']),
                ),
                const SizedBox(width: 20),
                Expanded(child: Text(s['name'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold))),
                IconButton(
                  onPressed: () => setState(() => _playingIndex = isPlaying ? null : index),
                  icon: Icon(isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded, size: 40, color: s['color']),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
