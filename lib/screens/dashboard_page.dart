import 'package:flutter/material.dart';
import '../services/mood_service.dart';
import '../services/story_service.dart';
import '../services/laravel_session_service.dart';
import '../services/notification_badge_service.dart';
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

  bool get _isFemaleUser {
    final gender = LaravelSessionService.gender?.toString().toLowerCase() ?? '';
    return gender.contains('perempuan');
  }

  String get _dashboardBackgroundAsset {
    return _isFemaleUser
        ? 'assets/image/backgournd_dashboard_cewe/backgournd_dashboard_cewe.png'
        : 'assets/image/dashbord.png';
  }

  String _featureIconPath(String maleAsset, String femaleAsset) {
    return _isFemaleUser ? femaleAsset : maleAsset;
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

  // ─── Helper: ambil label kondisi untuk kalimat deskripsi ───────────────────
  /// Mengubah string kondisi (mis. "Sangat Senang 😊") → kata natural
  /// yang cocok dipakai dalam kalimat "Mood kamu ___ dalam 14 hari terakhir."
  String _kondisiLabel(String kondisi) {
    final lower = kondisi.toLowerCase();
    if (lower.contains('sangat senang')) return 'sangat senang';
    if (lower.contains('antusias'))      return 'antusias';
    if (lower.contains('netral'))        return 'netral';
    if (lower.contains('terkejut'))      return 'terkejut';
    if (lower.contains('sedih'))         return 'sedih';
    if (lower.contains('takut'))         return 'takut';
    if (lower.contains('marah'))         return 'kurang baik';
    return 'stabil';
  }

  // ─── Konversi emosi_kode ke skor 1–7 (selaras dengan mood_calender_page) ───
  int _moodCodeToScore(int code) {
    switch (code) {
      case 1: return 7; // senang    → tertinggi
      case 2: return 2; // marah
      case 3: return 4; // sedih
      case 4: return 3; // takut
      case 5: return 6; // netral/biasa
      case 6: return 5; // terkejut
      case 7: return 1; // jijik     → terendah
      default: return 6;
    }
  }

  // ─── Konversi mood_label → emosi_kode (fallback jika kode tidak tersedia) ──
  int _moodLabelToCode(String label) {
    switch (label.toLowerCase().trim()) {
      case 'senang':    return 1;
      case 'marah':     return 2;
      case 'sedih':     return 3;
      case 'takut':     return 4;
      case 'netral':
      case 'biasa':     return 5;
      case 'terkejut':
      case 'kaget':     return 6;
      case 'antusias':  return 1; // antusias setara senang
      default:          return 5;
    }
  }

  Map<String, dynamic> _calculateRekapitulasiMood(
    List<Map<String, dynamic>> moods,
  ) {
    final today = _cleanDate(DateTime.now());
    final last14 = List.generate(
      14,
      (index) => today.subtract(Duration(days: 13 - index)),
    );

    // Kumpulkan rata-rata per hari terlebih dahulu (sama dengan calendar logic)
    final Map<DateTime, List<int>> dailyScores = {};

    for (final item in moods) {
      final dateTime = _parseDate(item['recorded_at'] ?? item['created_at']);
      if (dateTime == null) continue;
      final date = _cleanDate(dateTime);
      if (!last14.contains(date)) continue;

      // Prioritaskan emosi_kode, fallback ke mood_label
      final rawCode = item['emosi_kode'];
      int code;
      if (rawCode != null) {
        code = rawCode is num
            ? rawCode.toInt()
            : int.tryParse(rawCode.toString()) ?? 5;
      } else {
        final label = (item['mood_label'] ??
                item['mood'] ??
                item['name'] ??
                '')
            .toString();
        code = _moodLabelToCode(label);
      }

      final score = _moodCodeToScore(code);
      dailyScores.putIfAbsent(date, () => []).add(score);
    }

    // Hitung rata-rata keseluruhan dari rata-rata harian
    double totalAvg = 0;
    int daysWithData = dailyScores.length;

    dailyScores.forEach((_, scores) {
      totalAvg += scores.reduce((a, b) => a + b) / scores.length;
    });

    final double overallAvg =
        daysWithData > 0 ? totalAvg / daysWithData : 0;

    // ─── Pemetaan skor → mood emoji (7 kondisi) ────────────────────────────
    // Skala 1–7: >= 6.5 Senang, >= 5.5 Antusias, >= 4.5 Netral,
    //            >= 3.5 Terkejut, >= 2.5 Sedih, >= 1.5 Takut, < 1.5 Marah
    String kondisi;
    String imagePath;
    Color kondisiColor;

    if (daysWithData == 0) {
      kondisi    = 'Belum Terpantau';
      imagePath  = 'assets/image/biasa.png';
      kondisiColor = const Color(0xFF9E9E9E);
    } else if (overallAvg >= 6.5) {
      kondisi    = 'Sangat Senang';
      imagePath  = 'assets/image/senang.png';
      kondisiColor = const Color(0xFFF3C766);
    } else if (overallAvg >= 5.5) {
      kondisi    = 'Antusias';
      imagePath  = 'assets/image/antusias.png';
      kondisiColor = const Color(0xFFC8873B);
    } else if (overallAvg >= 4.5) {
      kondisi    = 'Netral';
      imagePath  = 'assets/image/biasa.png';
      kondisiColor = const Color(0xFF2C6D30);
    } else if (overallAvg >= 3.5) {
      kondisi    = 'Terkejut';
      imagePath  = 'assets/image/terkejut.png';
      kondisiColor = const Color(0xFF5E2E88);
    } else if (overallAvg >= 2.5) {
      kondisi    = 'Sedih';
      imagePath  = 'assets/image/sedih.png';
      kondisiColor = const Color(0xFF2B4791);
    } else if (overallAvg >= 1.5) {
      kondisi    = 'Takut';
      imagePath  = 'assets/image/takut.png';
      kondisiColor = const Color(0xFF3B4856);
    } else {
      kondisi    = 'Marah';
      imagePath  = 'assets/image/marah.png';
      kondisiColor = const Color(0xFFE53935);
    }

    final startDay = last14.first;
    final endDay = last14.last;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final dateRangeStr =
        '${startDay.day} ${months[startDay.month - 1]} ${startDay.year}'
        ' - '
        '${endDay.day} ${months[endDay.month - 1]} ${endDay.year}';

    return {
      'kondisi':      kondisi,
      'imagePath':    imagePath,
      'kondisiColor': kondisiColor,
      'dateRange':    dateRangeStr,
      'daysWithData': daysWithData,
      'overallAvg':   overallAvg,
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
                  border: Border.all(
                    color: Colors.black.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: SizedBox(width: 50, height: 50, child: icon),
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
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_circle,
                      color: Color(0xFF9E9E9E),
                      size: 18,
                    ),
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

  /// Kartu Notification dengan badge angka dari NotificationBadgeService
  Widget _buildNotificationCard(Color themeColor) {
    return ValueListenableBuilder<int>(
      valueListenable: NotificationBadgeService().totalBadge,
      builder: (context, badgeCount, _) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // ── Kartu utama ──────────────────────────────────────────────
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationPage(),
                  ),
                ).then((_) {
                  // Reset badge alarm setelah halaman ditutup
                  NotificationBadgeService().markNotificationPageOpened();
                  NotificationBadgeService().refresh();
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.85),
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
                    Positioned(
                      right: 0,
                      bottom: 0,
                      left: 0,
                      top: 0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          _featureIconPath(
                            'assets/image/notifikasi.png',
                            'assets/image/backgournd_dashboard_cewe/44.png',
                          ),
                          fit: BoxFit.contain,
                          alignment: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: const Text(
                        'Notification',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              offset: Offset(0, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Badge angka (merah) ──────────────────────────────────────
            if (badgeCount > 0)
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 22,
                    minHeight: 22,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: badgeCount < 10
                        ? BoxShape.circle
                        : BoxShape.rectangle,
                    borderRadius: badgeCount < 10
                        ? null
                        : BorderRadius.circular(11),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.5),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    badgeCount > 99 ? '99+' : '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
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
                    Shadow(
                      color: Colors.black45,
                      offset: Offset(0, 1),
                      blurRadius: 3,
                    ),
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
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),
              // Left Content
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.flash_on_rounded,
                            color: Colors.amber,
                            size: 14,
                          ),
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
                          Shadow(
                            color: Colors.black38,
                            offset: Offset(0, 1),
                            blurRadius: 4,
                          ),
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
                          Shadow(
                            color: Colors.black38,
                            offset: Offset(0, 1),
                            blurRadius: 4,
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

          final moods =
              (snapshot.data?['moods'] as List?)
                  ?.whereType<Map>()
                  .map((item) => Map<String, dynamic>.from(item))
                  .toList() ??
              [];
          final stories =
              (snapshot.data?['stories'] as List?)
                  ?.whereType<Map>()
                  .map((item) => Map<String, dynamic>.from(item))
                  .toList() ??
              [];
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
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(_dashboardBackgroundAsset),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Emolens',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Laporan harian membantu kami untuk mendukung kesejahteraan mental Anda.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 15),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    opaque: false,
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) => const StoryPage(),
                                    transitionsBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                          child,
                                        ) {
                                          return SlideTransition(
                                            position: animation.drive(
                                              Tween(
                                                begin: const Offset(0, 1),
                                                end: Offset.zero,
                                              ).chain(
                                                CurveTween(
                                                  curve: Curves.easeOutQuart,
                                                ),
                                              ),
                                            ),
                                            child: child,
                                          );
                                        },
                                  ),
                                ).then((result) {
                                  if (result == true) _reloadDashboard();
                                }),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Text(
                                      'Ceritakan Sekarang',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white,
                                      size: 12,
                                    ),
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
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.92),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.07),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                // Ukuran emoji responsif: 20% lebar card, min 70, max 100
                                final emojiSize = (constraints.maxWidth * 0.20)
                                    .clamp(70.0, 100.0);
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // ── Kolom kiri: semua teks ─────────────
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Baris 1: Judul + badge "14 Hari Terakhir"
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const Flexible(
                                                child: Text(
                                                  'Mood Summary',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                    color: Colors.black87,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              // Badge dengan ukuran text lebih kecil
                                              // agar tidak overflow di layar sempit
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 9,
                                                  vertical: 5,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  border: Border.all(
                                                    color: Colors.black54,
                                                    width: 1.2,
                                                  ),
                                                ),
                                                child: const Text(
                                                  '14 Hari Terakhir',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 3),

                                          // Baris 2: Rentang tanggal
                                          Text(
                                            rekapData['dateRange'],
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.black45,
                                            ),
                                          ),
                                          const SizedBox(height: 14),

                                          // Baris 3: Kalimat deskripsi (justified)
                                          Text(
                                            rekapData['daysWithData'] == 0
                                                ? 'Belum ada data mood dalam 14 hari terakhir. Mulai ceritakan perasaanmu setiap hari!'
                                                : 'Mood kamu ${_kondisiLabel(rekapData['kondisi'] as String)} dalam 14 hari terakhir. Tetap ceritakan perasaanmu setiap hari, agar kami dapat mendukung kesejahteraan mental Anda.',
                                            textAlign: TextAlign.justify,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black87,
                                              height: 1.65,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    // ── Kolom kanan: Emoji responsif ────────
                                    Image.asset(
                                      rekapData['imagePath'],
                                      height: emojiSize,
                                      width: emojiSize,
                                      fit: BoxFit.contain,
                                      errorBuilder: (c, e, s) => Icon(
                                        Icons.face_rounded,
                                        size: emojiSize,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Main Feature Section (White container with huge radius)
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(80),
                            ),
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 8),
                              // Feature Tiles
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildFeatureTile(
                                      title: 'Mood & Feelings',
                                      color: themeColor.withOpacity(0.25),
                                      icon: Image.asset(
                                        _featureIconPath(
                                          'assets/image/mood.png',
                                          'assets/image/backgournd_dashboard_cewe/mood.png',
                                        ),
                                        fit: BoxFit.contain,
                                      ),
                                      showBadge: true,
                                      onTap: () =>
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => const MoodPage(),
                                            ),
                                          ).then((result) {
                                            if (result == true)
                                              _reloadDashboard();
                                          }),
                                    ),
                                    const SizedBox(width: 15),
                                    _buildFeatureTile(
                                      title: 'Story Corner',
                                      color: themeColor.withOpacity(0.25),
                                      icon: Image.asset(
                                        _featureIconPath(
                                          'assets/image/pojok_cerita.png',
                                          'assets/image/backgournd_dashboard_cewe/pojok_cerita.png',
                                        ),
                                        fit: BoxFit.contain,
                                      ),
                                      showBadge: true,
                                      onTap: () =>
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              opaque: false,
                                              pageBuilder:
                                                  (
                                                    context,
                                                    animation,
                                                    secondaryAnimation,
                                                  ) => const StoryPage(),
                                              transitionsBuilder:
                                                  (
                                                    context,
                                                    animation,
                                                    secondaryAnimation,
                                                    child,
                                                  ) {
                                                    return SlideTransition(
                                                      position: animation.drive(
                                                        Tween(
                                                          begin: const Offset(
                                                            0,
                                                            1,
                                                          ),
                                                          end: Offset.zero,
                                                        ).chain(
                                                          CurveTween(
                                                            curve: Curves
                                                                .easeOutQuart,
                                                          ),
                                                        ),
                                                      ),
                                                      child: child,
                                                    );
                                                  },
                                            ),
                                          ).then((result) {
                                            if (result == true)
                                              _reloadDashboard();
                                          }),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 15),

                              // Layanan Section
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Services',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const Text(
                                      'Layanan dan hiburan terbaik untukmu',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black45,
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // Hero Card - Streak
                                    _buildLayananHeroCard(
                                      label: 'STREAK',
                                      title: 'Streak',
                                      subtitle:
                                          'Ceritakan perasaanmu atau lakukan aktivitas agar streak tetap menyala!',
                                      imagePath: _featureIconPath(
                                        'assets/image/streak.png',
                                        'assets/image/backgournd_dashboard_cewe/streak.png',
                                      ),
                                      color: themeColor,
                                      onTap: () =>
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  StreakPage(moods: recentDays),
                                            ),
                                          ).then((result) {
                                            if (result == true)
                                              _reloadDashboard();
                                          }),
                                    ),
                                    const SizedBox(height: 16),

                                    // 2x2 Grid for other features
                                    GridView.count(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      crossAxisCount: 2,
                                      childAspectRatio: 1.45,
                                      children: [
                                        _buildLayananCard(
                                          title: 'Daily Boost',
                                          imagePath: _featureIconPath(
                                            'assets/image/tantangan.png',
                                            'assets/image/backgournd_dashboard_cewe/11.png',
                                          ),
                                          color: themeColor,
                                          onTap: () =>
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      const DailyBoostPage(),
                                                ),
                                              ).then((result) {
                                                if (result == true)
                                                  _reloadDashboard();
                                              }),
                                        ),
                                        _buildLayananCard(
                                          title: 'Quotes',
                                          imagePath: _featureIconPath(
                                            'assets/image/quotes.png',
                                            'assets/image/backgournd_dashboard_cewe/33.png',
                                          ),
                                          color: themeColor,
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => QuotesPage(
                                                moods: moods,
                                                stories: stories,
                                              ),
                                            ),
                                          ),
                                        ),
                                        _buildLayananCard(
                                          title: 'Music',
                                          imagePath: _featureIconPath(
                                            'assets/image/musik.png',
                                            'assets/image/backgournd_dashboard_cewe/22.png',
                                          ),
                                          color: themeColor,
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => const MusicPage(),
                                            ),
                                          ),
                                        ),
                                        _buildNotificationCard(themeColor),
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
