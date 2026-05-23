import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/laravel_session_service.dart';
import 'feeling_page.dart';

class MoodPage extends StatefulWidget {
  const MoodPage({super.key});

  @override
  State<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends State<MoodPage> {
  int _selectedMoodIndex = 0;
  late PageController _pageController;
  // Large multiplier to allow "infinite" scrolling in both directions
  static const int _infiniteMultiplier = 1000;
  late int _initialPage;

  @override
  void initState() {
    super.initState();
    // Start at a large offset so user can scroll left from the first item
    _initialPage = _infiniteMultiplier ~/ 2 * 7; // multiple of moods.length
    _pageController =
        PageController(initialPage: _initialPage, viewportFraction: 0.6);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> moods = [
    {
      'image': 'assets/image/senang.png',
      'label': 'Senang',
      'description':
          'Rasa Senang adalah reaksi emosional terhadap pencapaian tujuan atau pengalaman yang menyenangkan, yang memotivasi individu untuk mengulangi perilaku yang menimbulkan kepuasan tersebut.',
      'gradientStart': const Color(0xFFFFF2B2), // Pastel Yellow
      'gradientEnd': const Color(0xFFF3C766),
      'textColor': const Color(0xFF8C6415),
    },
    {
      'image': 'assets/image/antusias.png',
      'label': 'Antusias',
      'description':
          'Rasa Antusias adalah perasaan gairah atau minat yang intens terhadap aktivitas tertentu, yang berfungsi memfokuskan perhatian dan meningkatkan keterlibatan dalam aktivitas tersebut.',
      'gradientStart': const Color(0xFFF6C884), // Pastel Orange/Brown
      'gradientEnd': const Color(0xFFC8873B),
      'textColor': const Color(0xFF6B451A),
    },
    {
      'image': 'assets/image/biasa.png',
      'label': 'Netral',
      'description':
          'Rasa Netral adalah pengalaman emosional yang tidak memicu respons fisiologis atau perilaku yang spesifik.',
      'gradientStart': const Color(0xFFE2F6E2), // Pastel Green
      'gradientEnd': const Color(0xFF8DE191),
      'textColor': const Color(0xFF2C6D30),
    },
    {
      'image': 'assets/image/terkejut.png',
      'label': 'Terkejut',
      'description':
          'Rasa Terkejut adalah emosi yang bersifat singkat dan intens, yang dapat bertransformasi menjadi emosi lain (misal takut atau senang), tergantung konteks stimulus.',
      'gradientStart': const Color(0xFFECD8FB), // Pastel Purple
      'gradientEnd': const Color(0xFFB878EE),
      'textColor': const Color(0xFF5E2E88),
    },
    {
      'image': 'assets/image/sedih.png',
      'label': 'Sedih',
      'description':
          'Rasa Sedih adalah emosi yang ditandai dengan perasaan duka, kesedihan, atau duka cita terhadap suatu kehilangan.',
      'gradientStart': const Color(0xFFCED9FA), // Pastel Blue
      'gradientEnd': const Color(0xFF86A3F3),
      'textColor': const Color(0xFF2B4791),
    },
    {
      'image': 'assets/image/takut.png',
      'label': 'Takut',
      'description':
          'Rasa Takut adalah emosi yang muncul sebagai respons terhadap ancaman atau bahaya yang dirasakan.',
      'gradientStart': const Color(0xFFD0D8E1), // Pastel Grey
      'gradientEnd': const Color(0xFF9CA6B2),
      'textColor': const Color(0xFF3B4856),
    },
    {
      'image': 'assets/image/marah.png',
      'label': 'Marah',
      'description':
          'Rasa Marah adalah reaksi emosional negatif yang menunjukkan ketidakpuasan atau frustasi terhadap situasi tertentu.',
      'gradientStart': const Color(0xFFF9CDCD), // Pastel Pink/Red
      'gradientEnd': const Color(0xFFDF7B7B),
      'textColor': const Color(0xFF7A2929),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final displayName = LaravelSessionService.displayName;

    return Scaffold(
      backgroundColor: const Color(0xFF768266),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/image/dashbord.png',
            fit: BoxFit.cover,
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x99556B2F),
                  Color(0xCC4A5E38),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.4,
                          ),
                          children: [
                            const TextSpan(text: 'Pilih emoji yang menggambarkan mood kamu, '),
                            TextSpan(
                              text: displayName.isNotEmpty ? displayName.split(' ').first : 'Kamu',
                              style: const TextStyle(color: Color(0xFFFFC107), fontWeight: FontWeight.w800),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Pilih emoji di bawah yang paling menggambarkan perasaanmu saat ini, agar kami bisa memberikan bantuan yang tepat.',
                        style: TextStyle(color: Colors.white, fontSize: 13, height: 1.5, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return ListenableBuilder(
                        listenable: _pageController,
                        builder: (context, child) {
                          double rawPage = _pageController.hasClients ? (_pageController.page ?? _initialPage.toDouble()) : _initialPage.toDouble();
                          double currentPageValue = rawPage % moods.length;
                          List<int> sortedIndices = List.generate(moods.length, (i) => i);
                          sortedIndices.sort((a, b) {
                            double distA = _circularDistance(a.toDouble(), currentPageValue, moods.length.toDouble());
                            double distB = _circularDistance(b.toDouble(), currentPageValue, moods.length.toDouble());
                            return distB.compareTo(distA);
                          });

                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              ...sortedIndices.map((index) {
                                final currentMood = moods[index];
                                double diff = _circularDiff(index.toDouble(), currentPageValue, moods.length.toDouble());
                                double absDiff = diff.abs();
                                if (absDiff > 2.5) return const SizedBox.shrink();

                                final cardWidth = constraints.maxWidth * 0.65;
                                final cardHeight = constraints.maxHeight * 0.85;
                                double scale, offsetX;
                                if (absDiff < 0.5) {
                                  scale = 1.0 - (absDiff * 0.04);
                                  offsetX = diff * cardWidth * 0.2;
                                } else if (absDiff < 1.5) {
                                  scale = 0.88 - ((absDiff - 0.5) * 0.04);
                                  offsetX = diff.sign * (cardWidth * 0.25 + (absDiff - 0.5) * cardWidth * 0.1);
                                } else {
                                  scale = 0.76 - ((absDiff - 1.5).clamp(0.0, 1.0) * 0.04);
                                  offsetX = diff.sign * (cardWidth * 0.42 + (absDiff - 1.5) * cardWidth * 0.1);
                                }

                                return Transform.translate(
                                  offset: Offset(offsetX, 0),
                                  child: Transform.scale(
                                    scale: scale,
                                    child: Container(
                                      width: cardWidth,
                                      height: cardHeight,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [currentMood['gradientStart'], currentMood['gradientEnd']],
                                        ),
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                                      child: absDiff < 0.5
                                          ? Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  currentMood['label'],
                                                  style: GoogleFonts.poppins(fontSize: 38, fontWeight: FontWeight.w900, color: currentMood['textColor'], letterSpacing: -0.5),
                                                ),
                                                const SizedBox(height: 16),
                                                Image.asset(currentMood['image'], width: 120, height: 120, fit: BoxFit.contain),
                                                const SizedBox(height: 16),
                                                Expanded(
                                                  child: SingleChildScrollView(
                                                    child: Text(
                                                      currentMood['description'],
                                                      textAlign: TextAlign.center,
                                                      style: const TextStyle(fontSize: 12, color: Colors.white, height: 1.5, fontWeight: FontWeight.w600),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Center(child: Image.asset(currentMood['image'], width: 80, height: 80, fit: BoxFit.contain)),
                                    ),
                                  ),
                                );
                              }),
                              Positioned.fill(
                                child: PageView.builder(
                                  controller: _pageController,
                                  physics: const BouncingScrollPhysics(),
                                  onPageChanged: (index) => setState(() => _selectedMoodIndex = index % moods.length),
                                  itemBuilder: (context, index) => const SizedBox.expand(),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Center(
                    child: SizedBox(
                      height: 48,
                      width: 160,
                      child: ElevatedButton(
                        onPressed: () {
                          String selectedMood = moods[_selectedMoodIndex]['label'];
                          Navigator.push(context, MaterialPageRoute(builder: (_) => FeelingPage(selectedMood: selectedMood)));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                          elevation: 4,
                        ),
                        child: const Text('Lanjutkan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF2E7D32))),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Calculate the shortest circular distance (always positive)
  double _circularDistance(double a, double b, double length) {
    double diff = (a - b) % length;
    if (diff > length / 2) diff -= length;
    if (diff < -length / 2) diff += length;
    return diff.abs();
  }

  /// Calculate the signed circular difference (for positioning left/right)
  double _circularDiff(double a, double b, double length) {
    double diff = (a - b) % length;
    if (diff > length / 2) diff -= length;
    if (diff < -length / 2) diff += length;
    return diff;
  }
}