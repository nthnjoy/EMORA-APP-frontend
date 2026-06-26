import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HappinessCardsView extends StatefulWidget {
  const HappinessCardsView({super.key});

  @override
  State<HappinessCardsView> createState() => _HappinessCardsViewState();
}

class _HappinessCardsViewState extends State<HappinessCardsView> {
  final List<String> _cards = [
    'Kamu sudah melakukan yang terbaik hari ini.',
    'Bernapaslah, semua akan baik-baik saja.',
    'Kecil bagi orang lain, tapi langkahmu besar bagimu.',
    'Istirahat bukan berarti menyerah.',
    'Dunia butuh senyummu besok pagi.',
    'Kamu berharga, tidak peduli seberapa banyak tugasmu.',
  ];
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF2F2),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close_rounded, color: Colors.black87), onPressed: () => Navigator.pop(context)),
        title: Text('Kartu Kebahagiaan', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => setState(() => _index = (_index + 1) % _cards.length),
              child: Container(
                width: 300,
                height: 400,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.1), blurRadius: 20)],
                ),
                child: Center(
                  child: Text(
                    _cards[_index],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red.shade400),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text('Ketuk kartu untuk melihat yang lain', style: TextStyle(color: Colors.red.shade200)),
          ],
        ),
      ),
    );
  }
}
