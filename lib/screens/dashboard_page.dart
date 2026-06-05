import 'package:flutter/material.dart';
import '../services/mood_service.dart';
import '../services/story_service.dart';
import '../services/laravel_session_service.dart';
import 'activity_page.dart';
import 'music_page.dart';
import 'notification_page.dart';
import 'profile_page.dart';
import 'quote_page.dart';
import 'streak_page.dart';
import 'story_page.dart';
import 'mood_page.dart';
import 'daily_boost_page.dart';
import '../services/theme_manager.dart';
import '../services/counselor_notification_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<Map<String, Object?>> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadDashboardData();
  }

  Future<Map<String, Object?>> _loadDashboardData() async {
    final moodResult = await MoodService.fetchMoods();
    final storyResult = await StoryService.fetchStories();

    final moods = <Map<String, Object?>>[];
    final rawMoodData = moodResult['data'];
    if (rawMoodData is List) {
      for (final item in rawMoodData) {
        if (item is Map) {
          moods.add(Map<String, Object?>.from(item));
        }
      }
    }

    final stories = <Map<String, Object?>>[];
    final rawStoryData = storyResult['data'];
    if (rawStoryData is List) {
      for (final item in rawStoryData) {
        if (item is Map) {
          stories.add(Map<String, Object?>.from(item));
        }
      }
    }

    return {
      'moods': moods,
      'stories': stories,
      'moodSuccess': moodResult['success'] == true,
      'storySuccess': storyResult['success'] == true,
      'moodMessage': moodResult['message'] ?? 'Gagal memuat mood',
      'storyMessage': storyResult['message'] ?? 'Gagal memuat cerita',
    };
  }

  Future<void> _reloadDashboard() async {
    // Silent reload to prevent "laggy" spinner appearance when returning
    final newData = await _loadDashboardData();
    if (mounted) {
      setState(() {
        _dashboardFuture = Future.value(newData);
      });
    }
  }

  DateTime _cleanDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty) return null;
    return DateTime.tryParse(text)?.toLocal();
  }

  List<Map<String, Object?>> _extractRecentDays(
    List<Map<String, Object?>> moods,
    List<Map<String, Object?>> stories,
  ) {
    final today = _cleanDate(DateTime.now());
    final last7 = List.generate(
      7,
      (index) => today.subtract(Duration(days: 6 - index)),
    );
    final counts = <DateTime, int>{};

    for (final item in moods) {
      final dateTime = _parseDate(item['recorded_at'] ?? item['created_at']);
      if (dateTime == null) continue;
      final date = _cleanDate(dateTime);
      if (!last7.contains(date)) continue;
      counts[date] = (counts[date] ?? 0) + 1;
    }

    for (final item in stories) {
      final dateTime = _parseDate(
        item['created_at'] ?? item['createdAt'] ?? item['recorded_at'],
      );
      if (dateTime == null) continue;
      final date = _cleanDate(dateTime);
      if (!last7.contains(date)) continue;
      counts[date] = (counts[date] ?? 0) + 1;
    }

    return last7.map<Map<String, Object?>>((date) {
      return <String, Object?>{'date': date, 'count': counts[date] ?? 0};
    }).toList();
  }

  Map<String, dynamic> _calculateRekapitulasiMood(List<Map<String, dynamic>> moods) {
    final today = _cleanDate(DateTime.now());
    final last14 = List.generate(
      14,
      (index) => today.subtract(Duration(days: 13 - index)),
    );

    int totalScore = 0;
    int count = 0;

    for (final item in moods) {
      final dateTime = _parseDate(item['recorded_at'] ?? item['created_at']);
      if (dateTime == null) continue;
      final date = _cleanDate(dateTime);
      if (!last14.contains(date)) continue;

      final moodName = (item['mood'] ?? item['name'] ?? '').toString().toLowerCase();
      
      int score = 3; // default netral
      if (moodName.contains('senang')) score = 5;
      else if (moodName.contains('antusias')) score = 4;
      else if (moodName.contains('netral') || moodName.contains('biasa')) score = 3;
      else if (moodName.contains('terkejut')) score = 3;
      else if (moodName.contains('sedih')) score = 2;
      else if (moodName.contains('takut')) score = 2;
      else if (moodName.contains('marah')) score = 1;

      totalScore += score;
      count++;
    }

    String kondisi = 'stabil';
    String imagePath = 'assets/image/senang.png';

    if (count > 0) {
      double average = totalScore / count;
      if (average > 4.0) {
        kondisi = 'sangat baik';
        imagePath = 'assets/image/senang.png';
      } else if (average >= 3.0) {
        kondisi = 'stabil';
        imagePath = 'assets/image/biasa.png';
      } else {
        kondisi = 'kurang baik';
        imagePath = 'assets/image/sedih.png';
      }
    } else {
      kondisi = 'belum terpantau sepenuhnya';
      imagePath = 'assets/image/biasa.png'; // fallback default
    }

    final startDay = last14.first;
    final endDay = last14.last;
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final dateRangeStr = '${startDay.day} ${months[startDay.month - 1]} ${startDay.year} - ${endDay.day} ${months[endDay.month - 1]} ${endDay.year}';

    return {
      'kondisi': kondisi,
      'imagePath': imagePath,
      'dateRange': dateRangeStr,
    };
  }

  Widget _buildFeatureTile({
    required String title,
    required Widget icon,
    required VoidCallback onTap,
    required Color color,
    bool showBadge = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 75,
                width: 75,
                decoration: BoxDecoration(
                  color: color, 
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.black.withOpacity(0.3), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: icon,
                  ),
                ),
              ),
              if (showBadge)
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1)),
                      ],
                    ),
                    child: const Icon(Icons.add_circle, color: Color(0xFF9E9E9E), size: 18),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A4A4A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayananCard({
    required String title,
    required String imagePath,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.85), 
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black12, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Character Image
            Positioned(
              right: 0,
              bottom: 0,
              left: 0,
              top: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomRight,
                ),
              ),
            ),
            // Title
            Positioned(
              bottom: 12,
              left: 12,
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  shadows: [
                    Shadow(color: Colors.black45, offset: Offset(0, 1), blurRadius: 3),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLayananHeroCard({
    required String label,
    required String title,
    required String subtitle,
    required String imagePath,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        constraints: const BoxConstraints(minHeight: 110),
        width: double.infinity,
        decoration: BoxDecoration(
          color: color.withOpacity(0.85),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black12, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Character / Mascot Image aligned to right
              Positioned(
                right: -10,
                bottom: -10,
                top: -10,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
              ),
              // Left Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.flash_on_rounded, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            label,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        shadows: [
                          Shadow(color: Colors.black38, offset: Offset(0, 1), blurRadius: 4),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        shadows: const [
                          Shadow(color: Colors.black38, offset: Offset(0, 1), blurRadius: 4),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).primaryColor;
    final bgColor = ThemeManager().backgroundColor;

    return Scaffold(
      backgroundColor: bgColor,
      body: FutureBuilder<Map<String, Object?>>(
        future: _dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final moods = (snapshot.data?['moods'] as List?)
                  ?.whereType<Map>()
                  .map((item) => Map<String, dynamic>.from(item))
                  .toList() ?? [];
          final stories = (snapshot.data?['stories'] as List?)
                  ?.whereType<Map>()
                  .map((item) => Map<String, dynamic>.from(item))
                  .toList() ?? [];
          final recentDays = _extractRecentDays(
            moods.map((e) => Map<String, Object?>.from(e)).toList(),
            stories.map((e) => Map<String, Object?>.from(e)).toList(),
          ).map((e) => Map<String, dynamic>.from(e)).toList();

          final rekapData = _calculateRekapitulasiMood(moods);

          return RefreshIndicator(
            onRefresh: _reloadDashboard,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Stack(
                children: [
                  // 1. Header Section
                  Container(
                    height: 480,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/image/dashbord.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.1),
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 2. Content Section
                  SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Emolens',
                                style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              const SizedBox(
                                width: 300,
                                child: Text(
                                  'Laporan harian membantu kami untuk mendukung kesejahteraan mental Anda.',
                                  style: TextStyle(color: Colors.white, fontSize: 16, height: 1.4),
                                ),
                              ),
                              const SizedBox(height: 15),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    opaque: false,
                                    pageBuilder: (context, animation, secondaryAnimation) => const StoryPage(),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      return SlideTransition(
                                        position: animation.drive(Tween(begin: const Offset(0, 1), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutQuart))),
                                        child: child,
                                      );
                                    },
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Text('Ceritakan Sekarang', style: TextStyle(color: Colors.white, fontSize: 14)),
                                    SizedBox(width: 5),
                                    Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Mood Rekap Card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text('Rekapitulasi Mood', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black12)),
                                            child: const Text('14 Hari Terakhir', style: TextStyle(fontSize: 9, color: Colors.black54)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(rekapData['dateRange'], style: TextStyle(fontSize: 9, color: Colors.grey[600])),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Mood kamu ${rekapData['kondisi']} dalam 7 hari terakhir. Tetap ceritakan perasaanmu setiap hari, agar kami dapat mendukung kesejahteraan mental Anda',
                                        style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.5),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Image.asset(rekapData['imagePath'], height: 75, errorBuilder: (c, e, s) => const Icon(Icons.face, size: 75, color: Colors.orange)),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Main Feature Section (White container with huge radius)
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(80)),
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 8),
                              // Feature Tiles
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildFeatureTile(
                                      title: 'Mood & Perasaan',
                                      color: const Color(0xFFC4D1BD),
                                      icon: Image.asset('assets/image/mood.png', fit: BoxFit.contain),
                                      showBadge: true,
                                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MoodPage())).then((result) {
                                        if (result == true) _reloadDashboard();
                                      }),
                                    ),
                                    const SizedBox(width: 15),
                                    _buildFeatureTile(
                                      title: 'Pojok Cerita',
                                      color: const Color(0xFFC4D1BD),
                                      icon: Image.asset('assets/image/pojok_cerita.png', fit: BoxFit.contain),
                                      showBadge: true,
                                      onTap: () => Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          opaque: false,
                                          pageBuilder: (context, animation, secondaryAnimation) => const StoryPage(),
                                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                            return SlideTransition(
                                              position: animation.drive(Tween(begin: const Offset(0, 1), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutQuart))),
                                              child: child,
                                            );
                                          },
                                        ),
                                      ).then((result) {
                                        if (result == true) _reloadDashboard();
                                      }),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 15),

                              // Layanan Section
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Layanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black87)),
                                    const Text('Layanan dan hiburan terbaik untukmu', style: TextStyle(fontSize: 12, color: Colors.black45)),
                                    const SizedBox(height: 16),
                                    
                                    // Hero Card - Streak
                                    _buildLayananHeroCard(
                                      label: 'STREAK',
                                      title: 'Streak',
                                      subtitle: 'Ceritakan perasaanmu atau lakukan aktivitas agar streak tetap menyala!',
                                      imagePath: 'assets/image/streak.png',
                                      color: themeColor,
                                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StreakPage(moods: recentDays))).then((result) {
                                        if (result == true) _reloadDashboard();
                                      }),
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // 2x2 Grid for other features
                                    GridView.count(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      crossAxisCount: 2,
                                      childAspectRatio: 1.45,
                                      children: [
                                        _buildLayananCard(title: 'Daily Boost', imagePath: 'assets/image/tantangan.png', color: themeColor, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyBoostPage())).then((result) {
                                          if (result == true) _reloadDashboard();
                                        })),
                                        _buildLayananCard(title: 'Quotes', imagePath: 'assets/image/quotes.png', color: themeColor, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuotesPage(moods: moods, stories: stories)))),
                                        _buildLayananCard(title: 'Musik', imagePath: 'assets/image/musik.png', color: themeColor, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MusicPage()))),
                                        _buildLayananCard(title: 'Notifikasi', imagePath: 'assets/image/notifikasi.png', color: themeColor, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationPage()))),
                                      ],
                                    ),
                                    const SizedBox(height: 50),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
}