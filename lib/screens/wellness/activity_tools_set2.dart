import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KindnessView extends StatefulWidget {
  const KindnessView({super.key});
  @override State<KindnessView> createState() => _KindnessViewState();
}
class _KindnessViewState extends State<KindnessView> {
  final TextEditingController _c = TextEditingController();
  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7ED),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context))),
      body: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
        Text('Tulis kebaikan yang kamu lakukan hari ini:', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        TextField(controller: _c, maxLines: 4, decoration: InputDecoration(hintText: 'Misal: Membantu teman, tersenyum pada orang asing...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)))),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Simpan Kebaikan'))
      ])),
    );
  }
}

class ProblemSolverView extends StatefulWidget {
  const ProblemSolverView({super.key});
  @override State<ProblemSolverView> createState() => _ProblemSolverViewState();
}
class _ProblemSolverViewState extends State<ProblemSolverView> {
  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context))),
      body: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Urutkan Masalahmu', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _step('1. Masalah Utama', 'Apa satu hal yang paling membebanimu?'),
        _step('2. Langkah Kecil', 'Apa satu hal kecil yang bisa kamu lakukan BESOK untuk masalah ini?'),
        _step('3. Dukungan', 'Siapa orang yang bisa membantumu?'),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Saya Siap Menghadapinya')))
      ])),
    );
  }
  Widget _step(String t, String s) {
    return Container(margin: const EdgeInsets.only(bottom: 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(t, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
      const SizedBox(height: 8),
      TextField(decoration: InputDecoration(hintText: s, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))))
    ]));
  }
}

class FutureLetterView extends StatefulWidget {
  const FutureLetterView({super.key});
  @override State<FutureLetterView> createState() => _FutureLetterViewState();
}
class _FutureLetterViewState extends State<FutureLetterView> {
  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(title: const Text('Surat Masa Depan'), backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context))),
      body: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
        const Text('Tulis surat untuk dirimu di masa depan. Kamu akan melihatnya kembali di Emolens.'),
        const SizedBox(height: 20),
        const Expanded(child: TextField(maxLines: null, decoration: InputDecoration(hintText: 'Halo diriku, aku ingin bilang...', border: InputBorder.none))),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Simpan & Kunci Surat'))
      ])),
    );
  }
}

class WaterDrinkView extends StatelessWidget {
  const WaterDrinkView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F2FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close_rounded, color: Colors.black87), onPressed: () => Navigator.pop(context)),
        title: Text('Minum Air Perlahan', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.water_drop_rounded, size: 80, color: Colors.blue),
            const SizedBox(height: 30),
            Text(
              'Ambil segelas air putih...',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Minumlah seteguk demi seteguk. Rasakan kesegaran air mengalir di kerongkonganmu. Fokuslah pada sensasi sejuknya.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, height: 1.6),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Sudah Selesai'),
            )
          ],
        ),
      ),
    );
  }
}
