import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/laravel_session_service.dart';

class StreakPage extends StatefulWidget {
  final List<Map<String, dynamic>> moods;

  const StreakPage({super.key, required this.moods});

  @override
  State<StreakPage> createState() => _StreakPageState();
}

class _StreakPageState extends State<StreakPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  int _currentStreak() {
    var count = 0;
    for (var i = widget.moods.length - 1; i >= 0; i--) {
      final entry = widget.moods[i];
      final value = entry['count'] as int? ?? 0;
      if (value > 0) {
        count += 1;
      } else {
        break;
      }
    }
    return count;
  }

  int _totalInput() {
    var total = 0;
    for (var item in widget.moods) {
      total += (item['count'] as int? ?? 0);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final streak = _currentStreak();
    final totalInput = _totalInput();
    final displayName = LaravelSessionService.displayName;
    final firstName = displayName.split(' ').first;

    
    Color bgColorStart;
    Color bgColorEnd;
    List<Color> flameColors;
    String titleText;
    String subtitleText;

    if (streak == 0) {
      
      bgColorStart = const Color(0xFF6B7280);
      bgColorEnd = const Color(0xFF374151);
      flameColors = [Colors.grey.shade300, Colors.grey.shade500, Colors.grey.shade700];
      titleText = 'Streaknya padam, \n$firstName...';
      subtitleText = 'Laporan emosional mu sekarang untuk membantu kami mendukung kesejahteraan emosional Anda.';
    } else if (streak < 5) {
      
      bgColorStart = const Color(0xFFFFB347);
      bgColorEnd = const Color(0xFFFF7B00);
      flameColors = [Colors.yellow.shade300, Colors.orange.shade500, Colors.deepOrange.shade600];
      titleText = 'Lencana Streak ditingkatkan, \n$firstName...';
      subtitleText = 'Laporan emosional mu dalam 7 hari ini sudah sebanyak $totalInput, terus laporkan emosional mu untuk membantu kami mendukung kesejahteraan emosional Anda.';
    } else {
      
      bgColorStart = const Color(0xFFFF4B4B);
      bgColorEnd = const Color(0xFFB90000);
      flameColors = [Colors.orange.shade300, Colors.red.shade600, Colors.red.shade900];
      titleText = 'Lencana Streak ditingkatkan, \n$firstName...';
      subtitleText = 'Luar biasa! Laporan emosional mu sangat konsisten. Terus laporkan emosional mu untuk membantu kami mendukung kesejahteraan emosional Anda.';
    }

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [bgColorStart, bgColorEnd],
                      ),
                    ),
                    child: Column(
                      children: [
                        
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
                              ),
                              const SizedBox(width: 15),
                              Container(
                                width: 45,
                                height: 45,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFB100FF),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                                  ],
                                ),
                                child: const Icon(Icons.local_fire_department, color: Colors.white, size: 26),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'EMOLENS',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFB100FF),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: const [
                                        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                                      ],
                                    ),
                                    child: Text(
                                      '$streak Streak',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 50),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: GoogleFonts.poppins(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                  children: [
                                    TextSpan(text: titleText.split(',')[0] + ',\n'),
                                    TextSpan(
                                      text: titleText.split(',')[1].trim(),
                                      style: TextStyle(
                                        color: streak == 0 ? Colors.redAccent : (streak < 5 ? Colors.red.shade700 : Colors.yellowAccent),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                subtitleText,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        GestureDetector(
                          onTap: () {
                            _animationController.forward(from: 0.5);
                          },
                          child: AnimatedBuilder(
                            animation: _scaleAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _scaleAnimation.value,
                                child: ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: flameColors,
                                  ).createShader(bounds),
                                  child: Icon(
                                    Icons.local_fire_department,
                                    size: 280,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 30,
                                        offset: const Offset(0, 15),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const Spacer(flex: 2),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
