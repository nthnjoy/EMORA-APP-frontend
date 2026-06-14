import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/mood_service.dart';
import '../services/laravel_session_service.dart';
import '../utils/ai_dialog.dart';
import '../services/activity_service.dart';
import 'story_page.dart';

class FeelingPage extends StatefulWidget {
  final String selectedMood;

  const FeelingPage({
    super.key,
    required this.selectedMood,
  });

  @override
  State<FeelingPage> createState() => _FeelingPageState();
}

class _FeelingPageState extends State<FeelingPage> {
  bool isSending = false;
  int _selectedFeelingIndex = 0;
  late PageController _pageController;
  static const int _infiniteMultiplier = 1000;
  late int _initialPage;

  // Feeling descriptions for each feeling
  final Map<String, String> feelingDescriptions = {
    // Senang
    'Gembira':
        'Gembira adalah emosi menyenangkan yang muncul saat kita mengalami sesuatu yang positif, mencapai tujuan, atau merasa terhubung dengan orang lain.',
    'Bangga':
        'Bangga adalah perasaan puas dan senang atas pencapaian diri sendiri atau orang yang kita sayangi.',
    'Bersyukur':
        'Bersyukur adalah perasaan menghargai hal-hal baik yang ada dalam hidup kita, baik besar maupun kecil.',
    'Ceria':
        'Ceria adalah perasaan ringan dan bahagia yang membuat kita ingin tersenyum dan menikmati momen saat ini.',
    // Antusias
    'Semangat':
        'Semangat adalah dorongan kuat dari dalam diri untuk melakukan sesuatu dengan penuh energi dan tekad.',
    'Energik':
        'Energik adalah perasaan penuh tenaga dan vitalitas yang membuat kita siap menghadapi tantangan.',
    'Kagum':
        'Kagum adalah perasaan takjub dan menghargai sesuatu yang luar biasa atau mengagumkan.',
    'Bergairah':
        'Bergairah adalah perasaan antusias yang kuat terhadap sesuatu yang sangat kita minati.',
    // Marah
    'Kesal':
        'Kesal adalah perasaan tidak nyaman yang muncul saat sesuatu tidak berjalan sesuai harapan.',
    'Jengkel':
        'Jengkel adalah rasa terganggu yang terus-menerus akibat situasi atau perilaku yang mengganggu.',
    'Benci':
        'Benci adalah perasaan negatif yang kuat terhadap seseorang atau sesuatu yang dianggap merugikan.',
    'Kecewa':
        'Kecewa adalah perasaan sedih karena harapan atau ekspektasi yang tidak terpenuhi.',
    // Sedih
    'Pilu':
        'Pilu adalah perasaan sedih yang mendalam yang membuat hati terasa berat dan ingin menangis.',
    'Depresi':
        'Depresi adalah perasaan sedih berkepanjangan yang mempengaruhi motivasi dan semangat hidup.',
    'Kesepian':
        'Kesepian adalah perasaan hampa karena kurangnya koneksi sosial atau kedekatan emosional.',
    'Putus Asa':
        'Putus asa adalah perasaan kehilangan harapan dan merasa tidak ada jalan keluar dari masalah.',
    // Takut
    'Cemas':
        'Cemas adalah perasaan khawatir berlebihan tentang sesuatu yang mungkin terjadi di masa depan.',
    'Khawatir':
        'Khawatir adalah perasaan gelisah ringan tentang kemungkinan hasil yang tidak diinginkan.',
    'Panik':
        'Panik adalah perasaan takut yang intens dan tiba-tiba yang membuat sulit berpikir jernih.',
    'Gelisah':
        'Gelisah adalah perasaan tidak tenang yang membuat sulit untuk diam dan rileks.',
    // Netral
    'Biasa Saja':
        'Biasa saja adalah kondisi emosi yang stabil tanpa perasaan positif atau negatif yang dominan.',
    'Stabil':
        'Stabil adalah kondisi emosi yang seimbang dan terkendali tanpa fluktuasi yang berarti.',
    'Tenang':
        'Tenang adalah perasaan damai dan rileks yang membuat pikiran dan tubuh terasa nyaman.',
    'Santai':
        'Santai adalah perasaan bebas dari tekanan atau stres, menikmati momen dengan ringan.',
    // Terkejut
    'Tercengang':
        'Tercengang adalah perasaan sangat terkejut hingga sulit berkata-kata atau bereaksi.',
    'Penasaran':
        'Penasaran adalah dorongan kuat untuk mengetahui atau memahami sesuatu yang belum diketahui.',
    'Tertarik':
        'Tertarik adalah perasaan ingin tahu lebih dalam tentang sesuatu yang menarik perhatian.',
    'Gelagapan':
        'Gelagapan adalah perasaan bingung dan gugup karena sesuatu yang tidak terduga.',
  };

  final Map<String, List<String>> feelingMap = {
    'Senang': [
      'Gembira',
      'Bangga',
      'Bersyukur',
      'Ceria',
    ],
    'Antusias': [
      'Semangat',
      'Energik',
      'Kagum',
      'Bergairah',
    ],
    'Netral': [
      'Biasa Saja',
      'Stabil',
      'Tenang',
      'Santai',
    ],
    'Terkejut': [
      'Tercengang',
      'Penasaran',
      'Tertarik',
      'Gelagapan',
    ],
    'Sedih': [
      'Pilu',
      'Depresi',
      'Kesepian',
      'Putus Asa',
    ],
    'Takut': [
      'Cemas',
      'Khawatir',
      'Panik',
      'Gelisah',
    ],
    'Marah': [
      'Kesal',
      'Jengkel',
      'Benci',
      'Kecewa',
    ],
  };

  final List<String> moodOrder = [
    'Senang',
    'Antusias',
    'Netral',
    'Terkejut',
    'Sedih',
    'Takut',
    'Marah',
  ];

  final Map<String, String> moodImages = {
    'Senang': 'assets/image/senang.png',
    'Antusias': 'assets/image/antusias.png',
    'Netral': 'assets/image/biasa.png',
    'Terkejut': 'assets/image/terkejut.png',
    'Sedih': 'assets/image/sedih.png',
    'Takut': 'assets/image/takut.png',
    'Marah': 'assets/image/marah.png',
  };

  late List<String> feelings;

  @override
  void initState() {
    super.initState();
    feelings = [];
    
    // First, add the feelings of the selected mood
    if (feelingMap.containsKey(widget.selectedMood)) {
      feelings.addAll(feelingMap[widget.selectedMood]!);
    }
    
    // Then add all other feelings
    feelingMap.forEach((key, list) {
      if (key != widget.selectedMood) {
        feelings.addAll(list);
      }
    });

    _initialPage = _infiniteMultiplier ~/ 2 * feelings.length;
    _pageController =
        PageController(initialPage: _initialPage, viewportFraction: 0.6);
  }

  String _getFeelingCategory(String feeling) {
    for (var entry in feelingMap.entries) {
      if (entry.value.contains(feeling)) {
        return entry.key;
      }
    }
    return 'Senang';
  }

  Color _getPrimaryColor(String category) {
    switch (category) {
      case 'Senang': return const Color(0xFFF3C766);
      case 'Antusias': return const Color(0xFFC8873B);
      case 'Netral': return const Color(0xFF8DE191);
      case 'Terkejut': return const Color(0xFFB878EE);
      case 'Sedih': return const Color(0xFF86A3F3);
      case 'Takut': return const Color(0xFF9CA6B2);
      case 'Marah': return const Color(0xFFDF7B7B);
      default: return const Color(0xFFF3C766);
    }
  }

  Color _getSideCardColor(String category) {
    switch (category) {
      case 'Senang': return const Color(0xFFFAD7A1);
      case 'Antusias': return const Color(0xFFF0B27A);
      case 'Netral': return const Color(0xFFA9DFBF);
      case 'Terkejut': return const Color(0xFFD7BDE2);
      case 'Sedih': return const Color(0xFFA9CCE3);
      case 'Takut': return const Color(0xFFBDC3C7);
      case 'Marah': return const Color(0xFFF5B7B1);
      default: return const Color(0xFFFAD7A1);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int _emotionCodeFromLabel(String moodLabel) {
    switch (moodLabel.toLowerCase()) {
      case 'senang':
        return 1;
      case 'marah':
        return 2;
      case 'sedih':
        return 3;
      case 'takut':
        return 4;
      case 'biasa':
      case 'netral':
        return 5;
      case 'terkejut':
        return 6;
      case 'jijik':
        return 7;
      default:
        return 5;
    }
  }

  Future<void> _submitMood() async {
    final selectedFeeling = feelings[_selectedFeelingIndex];

    setState(() => isSending = true);

    final result = await MoodService.createMood(
      moodLabel: widget.selectedMood,
      feeling: selectedFeeling,
      emotionCode: _emotionCodeFromLabel(widget.selectedMood),
    );

    if (!mounted) return;
    setState(() => isSending = false);

    if (result['success'] == true) {
      final feedback = result['ai_feedback'] ?? 'Terima kasih sudah berbagi perasaanmu hari ini!';
      
      await ActivityService.saveLastMood(widget.selectedMood, selectedFeeling);
      
      if (!mounted) return;
      await AiDialog.show(context, feedback);
      
      final int aiLevel = result['ai_level'] is int 
          ? result['ai_level'] 
          : int.tryParse(result['ai_level']?.toString() ?? '0') ?? 0;
          
      // Force trigger untuk akun testing Whisnu
      final String? userNim = LaravelSessionService.user?['nim']?.toString();
      final String? username = LaravelSessionService.user?['username']?.toString();
      final bool isTestingUser = userNim == '11423045' || username == 'whisnu';
          
      if (aiLevel == 3 || isTestingUser) {
        if (!mounted) return;
        await AiDialog.showWarning(
          context,
          'Sepertinya kamu tidak baik-baik saja. Coba lakukan konseling untuk membantu meredakan perasaanmu.',
        );
      }
      
      if (!mounted) return;
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Gagal mengirim mood')),
      );
    }
  }

  Future<void> _openStoryPage() async {
    final selectedFeeling = feelings[_selectedFeelingIndex];

    setState(() => isSending = true);

    final result = await MoodService.createMood(
      moodLabel: widget.selectedMood,
      feeling: selectedFeeling,
      emotionCode: _emotionCodeFromLabel(widget.selectedMood),
    );

    if (!mounted) return;
    setState(() => isSending = false);

    if (result['success'] == true) {
      await ActivityService.saveLastMood(widget.selectedMood, selectedFeeling);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mood dan perasaan berhasil disimpan.')),
      );
      Navigator.push(
        context,
        PageRouteBuilder(
          opaque: false, // Show FeelingPage underneath for better context
          pageBuilder: (context, animation, secondaryAnimation) => const StoryPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0); // Slide up from bottom
            const end = Offset.zero;
            const curve = Curves.easeOutQuart;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
        ),
      ).then((result) {
        if (result == true) {
          if (!mounted) return;
          Navigator.pop(context, true);
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Gagal menyimpan mood')),
      );
    }
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

  Widget _buildMoodRow(String currentCategory) {
    return Container(
      height: 90,
      margin: const EdgeInsets.only(top: 5, bottom: 5),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: moodOrder.length,
        itemBuilder: (context, index) {
          String mood = moodOrder[index];
          bool isSelected = mood == currentCategory;
          Color color = _getPrimaryColor(mood);
          
          return GestureDetector(
            onTap: () {
               // Find index of first feeling in this mood
               int targetIndex = feelings.indexOf(feelingMap[mood]!.first);
               if (targetIndex != -1) {
                  double currentPage = _pageController.page ?? _initialPage.toDouble();
                  int currentMod = currentPage.round() % feelings.length;
                  int diff = targetIndex - currentMod;
                  
                  if (diff > feelings.length / 2) diff -= feelings.length;
                  if (diff < -feelings.length / 2) diff += feelings.length;
                  
                  _pageController.animateToPage(
                    currentPage.round() + diff,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
               }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 15),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: Colors.white, width: 2.5) : null,
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: color.withOpacity(0.6),
                          blurRadius: 8,
                          spreadRadius: 2,
                        )
                      ] : [],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Image.asset(
                        moodImages[mood]!,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.sentiment_neutral, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mood,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final displayName = LaravelSessionService.displayName;

    // Use the selected index (maintained by PageView.onPageChanged) for header
    int currentIndex = _selectedFeelingIndex % (feelings.isNotEmpty ? feelings.length : 1);
    String currentCategory = feelings.isNotEmpty ? _getFeelingCategory(feelings[currentIndex]) : 'Senang';

    return Scaffold(
      backgroundColor: const Color(0xFFB1D86D), // Solid pastel green matching the screenshot
      body: SafeArea(
        child: Column(
          children: [
            // Top section with header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Back button row
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
                            color: Colors.black87,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Header text
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Pilih perasaan yang\nmenggambarkan mood kamu,\n',
                        ),
                        TextSpan(
                          text: displayName.isNotEmpty
                              ? displayName.split(' ').first
                              : 'Kamu',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFF39C12), // Vibrant yellow/orange
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Description
                  Text(
                    'Pilih perasaan di bawah yang paling\nmenggambarkan kamu saat ini, agar kami bisa\nmemberikan bantuan yang tepat.',
                    style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontSize: 12,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal Mood selection row
            _buildMoodRow(currentCategory),

            // Swipeable stacked card carousel
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return ListenableBuilder(
                    listenable: _pageController,
                    builder: (context, child) {
                      // Recompute the current page here so transforms use the
                      // live PageController.page value (same approach as MoodPage)
                      double rawPageLocal = _pageController.hasClients
                          ? (_pageController.page ?? _initialPage.toDouble())
                          : _initialPage.toDouble();
                      double currentPageValue = rawPageLocal % feelings.length;

                      // Sort by distance so furthest cards render first (behind)
                      List<int> sortedIndices = List.generate(feelings.length, (i) => i);
                      sortedIndices.sort((a, b) {
                        double distA = _circularDistance(
                            a.toDouble(),
                            currentPageValue,
                            feelings.length.toDouble());
                        double distB = _circularDistance(
                            b.toDouble(),
                            currentPageValue,
                            feelings.length.toDouble());
                        return distB.compareTo(distA);
                      });

                      // Match mood card sizing: 65% width, 85% height
                      final cardWidth = constraints.maxWidth * 0.65;
                      final cardHeight = constraints.maxHeight * 0.85;

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          ...sortedIndices.map((index) {
                            final feeling = feelings[index];
                            final description = feelingDescriptions[feeling] ?? '';
                            double diff = _circularDiff(
                                index.toDouble(),
                                currentPageValue,
                                feelings.length.toDouble());
                            double absDiff = diff.abs();

                            if (absDiff > 2.5) {
                              return const SizedBox.shrink();
                            }

                            // Use same interactive stacking math as MoodPage for
                            // consistent left/right swipe behavior and scaling.
                            double scale;
                            double offsetX;
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
                            scale = scale.clamp(0.5, 1.0);
                            double opacity = 1.0;

                            bool isCenter = absDiff < 0.5;
                            String cardCategory = _getFeelingCategory(feeling);
                            Color primaryColor = _getPrimaryColor(cardCategory);
                            Color cardColor = isCenter ? Colors.white : _getSideCardColor(cardCategory);

                            return Transform.translate(
                              offset: Offset(offsetX, 0),
                              child: Transform.scale(
                                scale: scale,
                                child: Opacity(
                                  opacity: opacity,
                                  child: Container(
                                    width: cardWidth,
                                    height: cardHeight,
                                    decoration: BoxDecoration(
                                      color: cardColor,
                                      borderRadius: BorderRadius.circular(20),
                                      border: isCenter 
                                          ? Border.all(color: primaryColor, width: 5.0)
                                          : Border.all(color: Colors.black12, width: 1.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: isCenter
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(16),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                vertical: 32,
                                                horizontal: 24,
                                              ),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    feeling,
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 32,
                                                      fontWeight: FontWeight.w900,
                                                      color: primaryColor,
                                                      shadows: [
                                                        // Deep shadow (shifted slightly more to show behind outline)
                                                        Shadow(
                                                          color: Colors.black.withOpacity(0.25),
                                                          blurRadius: 8,
                                                          offset: const Offset(0, 5),
                                                        ),
                                                        // Outline effect using multiple shadows (white)
                                                        const Shadow(offset: Offset(-2.0, -2.0), color: Colors.white),
                                                        const Shadow(offset: Offset(2.0, -2.0), color: Colors.white),
                                                        const Shadow(offset: Offset(2.0, 2.0), color: Colors.white),
                                                        const Shadow(offset: Offset(-2.0, 2.0), color: Colors.white),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 24),
                                                  Expanded(
                                                    child: SingleChildScrollView(
                                                      child: Text(
                                                        description,
                                                        textAlign: TextAlign.center,
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 12,
                                                          color: Colors.black87,
                                                          height: 1.5,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                ),
                              ),
                            );
                          }),

                          // Invisible PageView for swipe gestures
                          Positioned.fill(
                            child: PageView.builder(
                              controller: _pageController,
                              physics: const BouncingScrollPhysics(),
                              onPageChanged: (index) {
                                setState(() {
                                  _selectedFeelingIndex =
                                      index % feelings.length;
                                });
                              },
                              itemBuilder: (context, index) {
                                return const SizedBox.expand();
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),

            // Bottom buttons: Kirim and Cerita
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Kirim button (outlined)
                  SizedBox(
                    height: 40,
                    width: 120,
                    child: OutlinedButton(
                      onPressed: isSending ? null : _submitMood,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: isSending
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF2E7D32),
                              ),
                            )
                          : Text(
                              'Kirim',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2E7D32),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Cerita button (filled green)
                  SizedBox(
                    height: 40,
                    width: 120,
                    child: ElevatedButton(
                      onPressed: isSending ? null : _openStoryPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        'Cerita',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}