import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BodyScanView extends StatelessWidget {
  const BodyScanView({super.key});
  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDFA),
      appBar: AppBar(title: const Text('Scan Tubuh')),
      body: Center(child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.accessibility_new_rounded, size: 80, color: Colors.teal),
          const SizedBox(height: 30),
          Text('Fokus pada bagian tubuhmu satu per satu...', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const Text('Mulai dari ujung kaki, rasakan setiap sensasinya, lalu gerakkan perhatianmu perlahan ke atas hingga ubun-ubun.', textAlign: TextAlign.center),
        ]),
      )),
    );
  }
}

class MuscleRelaxView extends StatefulWidget {
  const MuscleRelaxView({super.key});
  @override State<MuscleRelaxView> createState() => _MuscleRelaxViewState();
}
class _MuscleRelaxViewState extends State<MuscleRelaxView> {
  bool _tensed = false;
  int _step = 0;
  final List<String> _parts = ['Tangan & Lengan', 'Bahu & Leher', 'Wajah & Rahang', 'Perut & Kaki'];

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context))),
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('RELAKSASI OTOT', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2)),
        const SizedBox(height: 40),
        Text(_parts[_step % _parts.length].toUpperCase(), style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Text(_tensed ? 'TAHAN KENCANG...' : 'RILEKSKAN...', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 18)),
        const SizedBox(height: 60),
        GestureDetector(
          onLongPressStart: (_) => setState(() => _tensed = true),
          onLongPressEnd: (_) => setState(() { _tensed = false; _step++; }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 150, height: 150,
            decoration: BoxDecoration(shape: BoxShape.circle, color: _tensed ? Colors.redAccent : Colors.cyanAccent, boxShadow: [BoxShadow(color: (_tensed ? Colors.redAccent : Colors.cyanAccent).withOpacity(0.5), blurRadius: 30)]),
            child: Center(child: Text(_tensed ? 'LEPAS' : 'TEKAN', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, color: Colors.black))),
          ),
        ),
        const SizedBox(height: 40),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 40), child: Text('Tekan tombol untuk mengencangkan otot, lalu lepaskan untuk merasakan relaksasinya.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 12))),
      ])),
    );
  }
}

class CandleView extends StatefulWidget {
  const CandleView({super.key});
  @override State<CandleView> createState() => _CandleViewState();
}
class _CandleViewState extends State<CandleView> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Visual Keheningan'), backgroundColor: Colors.transparent),
      body: Center(child: AnimatedBuilder(animation: _c, builder: (context, child) {
        return Icon(Icons.local_fire_department, size: 100 + (_c.value * 20), color: Colors.orange);
      })),
    );
  }
}

class HeartbeatFocusView extends StatelessWidget {
  const HeartbeatFocusView({super.key});
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fokus Detak Jantung')),
      body: const Center(child: Text('Letakkan tangan di dada, rasakan setiap detaknya...')),
    );
  }
}

class WalkingView extends StatelessWidget {
  const WalkingView({super.key});
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Instruksi Jalan Santai')),
      body: const Center(child: Text('Bangun dari dudukmu, berjalanlah 10 langkah ke depan dan belakang dengan penuh kesadaran.')),
    );
  }
}

class FocusTargetView extends StatelessWidget {
  const FocusTargetView({super.key});
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Target Fokus')),
      body: const Center(child: Text('Apa 1 hal paling penting yang ingin kamu selesaikan sekarang?')),
    );
  }
}
