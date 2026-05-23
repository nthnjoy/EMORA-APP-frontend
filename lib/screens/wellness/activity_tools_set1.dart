import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StretchingView extends StatelessWidget {
  const StretchingView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> steps = [
      {'title': 'Leher (Neck)', 'desc': 'Putar leher perlahan ke kiri dan kanan selama 10 hitungan.'},
      {'title': 'Bahu (Shoulder)', 'desc': 'Angkat bahu ke atas, tahan 5 detik, lalu lepaskan.'},
      {'title': 'Tangan (Arms)', 'desc': 'Renggangkan tangan ke depan, tarik jemari ke arah tubuh.'},
      {'title': 'Punggung (Back)', 'desc': 'Duduk tegak, peluk sandaran kursi, lalu putar tubuh perlahan.'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7FEE7),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close_rounded, color: Colors.black87), onPressed: () => Navigator.pop(context)),
        title: Text('Peregangan Ringan', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: steps.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: Colors.lime.shade100, child: Text('${index + 1}')),
              title: Text(steps[index]['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(steps[index]['desc']!),
              contentPadding: const EdgeInsets.all(16),
            ),
          );
        },
      ),
    );
  }
}

class VisualizationView extends StatefulWidget {
  const VisualizationView({super.key});
  @override State<VisualizationView> createState() => _VisualizationViewState();
}
class _VisualizationViewState extends State<VisualizationView> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context))),
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        AnimatedBuilder(animation: _c, builder: (context, _) => Container(
          width: 100 + (_c.value * 50), height: 100 + (_c.value * 50),
          decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [Colors.cyanAccent, Colors.transparent]), boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.3), blurRadius: 30)]),
        )),
        const SizedBox(height: 60),
        Text('VISUALISASI POSITIF', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Tutup matamu dan bayangkan cahaya hangat dari dadamu menyebar ke seluruh tubuh, menyembuhkan setiap beban yang kau bawa hari ini...',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16, height: 1.6),
          ),
        ),
      ])),
    );
  }
}
