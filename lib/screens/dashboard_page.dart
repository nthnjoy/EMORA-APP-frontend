import 'package:flutter/material.dart';
import '../services/mood_service.dart';
import '../services/story_service.dart';
import 'activity_page.dart';
import 'ai_page.dart';
import 'challenge_page.dart';
import 'music_page.dart';
import 'notification_page.dart';
import 'quote_page.dart';
import 'streak_page.dart';
import 'story_page.dart';
import 'mood_page.dart';

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
    setState(() {
      _dashboardFuture = _loadDashboardData();
    });
  }

  DateTime _cleanDate(DateTime date) => DateTime(date.year, date.month, date.day);

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
    final last7 = List.generate(7, (index) => today.subtract(Duration(days: 6 - index)));
    final counts = <DateTime, int>{};

    for (final item in moods) {
      final dateTime = _parseDate(item['recorded_at'] ?? item['created_at']);
      if (dateTime == null) continue;
      final date = _cleanDate(dateTime);
      if (!last7.contains(date)) continue;
      counts[date] = (counts[date] ?? 0) + 1;
    }

    for (final item in stories) {
      final dateTime = _parseDate(item['created_at'] ?? item['createdAt'] ?? item['recorded_at']);
      if (dateTime == null) continue;
      final date = _cleanDate(dateTime);
      if (!last7.contains(date)) continue;
      counts[date] = (counts[date] ?? 0) + 1;
    }

    return last7.map<Map<String, Object?>>((date) {
      return <String, Object?>{
        'date': date,
        'count': counts[date] ?? 0,
      };
    }).toList();
  }

  Widget _buildFeatureTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              child: Icon(icon, color: Colors.black87, size: 26),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(List<Map<String, Object?>> recentDays) {
    final today = _cleanDate(DateTime.now());
    final todaysCount = recentDays
        .firstWhere((entry) => entry['date'] == today, orElse: () => {'count': 0})['count'] as int;
    final isTodayActive = todaysCount > 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isTodayActive ? Colors.deepPurple : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Streak Hari Ini',
            style: TextStyle(
              color: isTodayActive ? Colors.white : Colors.black87,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isTodayActive ? '$todaysCount Input' : 'Belum ada input hari ini',
            style: TextStyle(
              color: isTodayActive ? Colors.white : Colors.black87,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: recentDays.map((entry) {
              final count = entry['count'] as int;
              final isActive = count > 0;
              final date = entry['date'] as DateTime;
              final label = '${date.day}';
              return Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.white : Colors.transparent,
                      border: Border.all(
                        color: isActive ? Colors.white : Colors.white70,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      count > 0 ? count.toString() : '-',
                      style: TextStyle(
                        color: isActive ? Colors.deepPurple : Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: isTodayActive ? Colors.white70 : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isTodayActive ? Colors.white : Colors.black54,
                ),
                foregroundColor: isTodayActive ? Colors.white : Colors.black87,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StreakPage(
                      moods: recentDays,
                    ),
                  ),
                );
              },
              child: const Text('Lihat Detail Streak'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(int totalInputs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5B42FF), Color(0xFF8D67FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NAMA APLIKASI',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Laporan harian membantu kami untuk mendukung kesejahteraan mental Anda.',
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ringkasan Hari Ini',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$totalInputs Input',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text(
                        'Aktif',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _reloadDashboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: FutureBuilder<Map<String, Object?>>(
              future: _dashboardFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                if (!snapshot.hasData) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: const Center(child: Text('Gagal memuat dashboard.')),
                  );
                }

                final rawMoods = snapshot.data?['moods'];
                final rawStories = snapshot.data?['stories'];
                final moods = rawMoods is List
                    ? rawMoods
                        .where((item) => item is Map)
                        .map((item) => Map<String, Object?>.from(item as Map))
                        .toList()
                    : <Map<String, Object?>>[];
                final stories = rawStories is List
                    ? rawStories
                        .where((item) => item is Map)
                        .map((item) => Map<String, Object?>.from(item as Map))
                        .toList()
                    : <Map<String, Object?>>[];
                final recentDays = _extractRecentDays(moods, stories);
                final today = _cleanDate(DateTime.now());
                final todayCount = recentDays
                        .firstWhere((entry) => entry['date'] == today,
                            orElse: () => {'count': 0})['count'] as int;
                final totalInputs = moods.length + stories.length;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Halo, Alex',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Apa yang ingin kamu bagikan hari ini?',
                                style: TextStyle(fontSize: 14, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.deepPurple.shade100,
                          child: const Icon(Icons.person, color: Colors.deepPurple),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildHeaderCard(totalInputs),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MoodPage(),
                              ),
                            ).then((_) => _reloadDashboard()),
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 12,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Icon(Icons.emoji_emotions, color: Colors.deepPurple),
                                  SizedBox(height: 14),
                                  Text(
                                    'Mood & Perasaan',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 6),
                                  Text('Mulai laporan perasaanmu'),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const StoryPage()),
                            ).then((_) => _reloadDashboard()),
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 12,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Icon(Icons.book, color: Colors.deepPurple),
                                  SizedBox(height: 14),
                                  Text(
                                    'Pojok Cerita',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 6),
                                  Text('Curahkan perasaanmu di sini'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildStreakCard(recentDays),
                    const SizedBox(height: 20),
                    const Text(
                      'Fitur Lainnya',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 14),
                    GridView(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.95,
                      ),
                      children: [
                        _buildFeatureTile(
                          title: 'AI',
                          icon: Icons.smart_toy,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AiPage()),
                          ),
                        ),
                        _buildFeatureTile(
                          title: 'Tantangan',
                          icon: Icons.flag,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ChallengePage()),
                          ),
                        ),
                        _buildFeatureTile(
                          title: 'Musik',
                          icon: Icons.music_note,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const MusicPage()),
                          ),
                        ),
                        _buildFeatureTile(
                          title: 'Quotes',
                          icon: Icons.format_quote,
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
                        _buildFeatureTile(
                          title: 'Notifikasi',
                          icon: Icons.notifications,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const NotificationPage()),
                          ),
                        ),
                        _buildFeatureTile(
                          title: 'Aktivitas',
                          icon: Icons.directions_run,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ActivityPage()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

