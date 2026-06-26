import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AffirmationSwiperView extends StatefulWidget {
  const AffirmationSwiperView({super.key});

  @override
  State<AffirmationSwiperView> createState() => _AffirmationSwiperViewState();
}

class _AffirmationSwiperViewState extends State<AffirmationSwiperView> {
  final List<Map<String, dynamic>> _affirmations = [
    {'text': 'Saya cukup apa adanya.', 'color': Colors.orange},
    {'text': 'Hari ini adalah awal yang baru.', 'color': Colors.blue},
    {'text': 'Saya memilih untuk tenang.', 'color': Colors.teal},
    {'text': 'Kesalahan adalah pelajaran.', 'color': Colors.purple},
    {'text': 'Saya berharga dan dicintai.', 'color': Colors.pink},
    {'text': 'Fokus pada apa yang bisa saya kontrol.', 'color': Colors.indigo},
  ];

  final PageController _controller = PageController(viewportFraction: 0.8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Kartu Positif', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close_rounded, color: Colors.black87), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          Text(
            'Geser kartu untuk afirmasi lainnya.',
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _affirmations.length,
              itemBuilder: (context, index) {
                final item = _affirmations[index];
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    double value = 1.0;
                    if (_controller.position.haveDimensions) {
                      value = _controller.page! - index;
                      value = (1 - (value.abs() * 0.2)).clamp(0.0, 1.0);
                    }
                    return Center(
                      child: Transform.scale(
                        scale: value,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: item['color'],
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: item['color'].withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          child: Center(
                            child: Text(
                              item['text'],
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}
