import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GuidePage extends StatefulWidget {
  const GuidePage({super.key});

  @override
  State<GuidePage> createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  final PageController _controller = PageController();
  Timer? _autoTimer;
  int _index = 0;

  final List<Map<String, String>> _pages = [
    {'title': 'Selamat Datang', 'text': 'Selamat datang di Emolens — aplikasi untuk mendukung kesejahteraanmu.'},
    {'title': 'Fitur Musik', 'text': 'Dengarkan lagu berdasarkan mood. Ketuk mood, pilih lagu, lalu mainkan.'},
    {'title': 'Cerita & Dukungan', 'text': 'Kirim cerita dan dapatkan masukan AI. Cerita bersifat pribadi.'},
    {'title': 'Pengingat', 'text': 'Aktifkan pengingat harian pada waktu pilihanmu untuk cek-in singkat.'},
    {'title': 'Tema & Poin', 'text': 'Tukar poin dengan tema tampilan. Kumpulkan poin lewat aktivitas.'},
  ];

  @override
  void initState() {
    super.initState();
    _startAutoAdvance();
  }

  void _startAutoAdvance() {
    _autoTimer?.cancel();
    _autoTimer = Timer(const Duration(seconds: 3), () {
      _next();
    });
  }

  void _next() {
    if (_index < _pages.length - 1) {
      _index++;
      _controller.animateToPage(_index, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
      _startAutoAdvance();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _onPageChanged(int i) {
    setState(() => _index = i);
    _startAutoAdvance();
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panduan Aplikasi')),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: _onPageChanged,
              itemCount: _pages.length,
              itemBuilder: (context, idx) {
                final item = _pages[idx];
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item['title']!, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 16),
                      Text(item['text']!, style: GoogleFonts.poppins(fontSize: 16), textAlign: TextAlign.center),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _index ? Theme.of(context).primaryColor : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    )),
                  ),
                ),
                ElevatedButton(
                  onPressed: _next,
                  child: Text(_index < _pages.length - 1 ? 'Selanjutnya' : 'Selesai'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
