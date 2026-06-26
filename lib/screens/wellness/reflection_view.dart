import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReflectionView extends StatefulWidget {
  const ReflectionView({super.key});

  @override
  State<ReflectionView> createState() => _ReflectionViewState();
}

class _ReflectionViewState extends State<ReflectionView> {
  final PageController _pageController = PageController();
  final List<String> _prompts = [
    'Apa satu hal yang membuatmu bangga pada dirimu hari ini?',
    'Siapa orang yang paling ingin kamu ucapkan terima kasih saat ini?',
    'Jika kamu bisa mengubah satu hal kecil besok, apa itu?',
    'Apa pelajaran berharga yang kamu dapatkan minggu ini?',
  ];
  final Map<int, String> _responses = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close_rounded, color: Colors.black87), onPressed: () => Navigator.pop(context)),
        title: Text('Jurnal Refleksi', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: _prompts.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                  child: Column(
                    children: [
                      Text('Tanya Diri # ${index + 1}', style: TextStyle(color: Colors.pink.shade300, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Text(
                        _prompts[index],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        maxLines: 5,
                        onChanged: (v) => _responses[index] = v,
                        decoration: InputDecoration(
                          hintText: 'Tulis pikiranmu...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (index > 0)
                      TextButton(onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut), child: const Text('Sebelumnya')),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        if (index < _prompts.length - 1) {
                          _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                        } else {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Refleksi tersimpan di hatimu.')));
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.pink.shade400, foregroundColor: Colors.white),
                      child: Text(index < _prompts.length - 1 ? 'Lanjut' : 'Selesai'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
