import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/laravel_session_service.dart';
import '../services/user_service.dart';

// ──────────────────────────────────────────────────
// Model
// ──────────────────────────────────────────────────
class DailyBoostItem {
  final String emoji;
  final String title;
  final String description;
  final String duration;
  final int durationSeconds; 
  final String category;
  final Color color;
  final String flavorText;

  const DailyBoostItem({
    required this.emoji,
    required this.title,
    required this.description,
    required this.duration,
    required this.durationSeconds,
    required this.category,
    required this.color,
    this.flavorText = 'Tingkatkan fokusmu, raih prestasimu!',
  });
}

// ──────────────────────────────────────────────────
// 10 Misi Daily Boost (Pool)
// ──────────────────────────────────────────────────
const List<DailyBoostItem> _allDailyBoosts = [
  DailyBoostItem(
    emoji: '✍️', title: 'Deep Work 5 Menit', description: 'Matikan semua notifikasi, fokus hanya pada satu tugas kuliah tanpa distraksi.', duration: '5 menit', durationSeconds: 300, category: 'Fokus', color: Color(0xFF6366F1), flavorText: 'Satu langkah kecil untuk IPK impian.',
  ),
  DailyBoostItem(
    emoji: '🚶‍♂️', title: 'Jalan Santai ke Kantin', description: 'Berjalan perlahan tanpa melihat HP. Perhatikan lingkungan kampus di sekitarmu.', duration: '2 menit', durationSeconds: 120, category: 'Gerak', color: Color(0xFF10B981), flavorText: 'Beri matamu istirahat dari cahaya biru.',
  ),
  DailyBoostItem(
    emoji: '🧘', title: 'Napas Anti-Insecure', description: 'Tarik napas dalam 4 hitungan, tahan 4, hembuskan 4. Kamu berharga dan mampu!', duration: '1 menit', durationSeconds: 60, category: 'Pernapasan', color: Color(0xFF8B5CF6), flavorText: 'Tenangkan diri sebelum presentasi.',
  ),
  DailyBoostItem(
    emoji: '🥤', title: 'Hidrasi di Kelas', description: 'Minum air putih satu botol kecil perlahan. Otak butuh air untuk berpikir jernih.', duration: '1 menit', durationSeconds: 60, category: 'Segar', color: Color(0xFF3B82F6), flavorText: 'Air adalah bensin bagi otakmu.',
  ),
  DailyBoostItem(
    emoji: '🦒', title: 'Peregangan Leher Nugas', description: 'Putar leher perlahan ke kiri dan kanan. Hilangkan beban nugas di pundakmu.', duration: '1 menit', durationSeconds: 60, category: 'Peregangan', color: Color(0xFFF43F5E), flavorText: 'Leher kaku bukan bagian dari tugas kuliah.',
  ),
  DailyBoostItem(
    emoji: '☁️', title: 'Melamun Berfaedah', description: 'Tutup laptop, pejamkan mata, bayangkan tempat paling damai selama 2 menit.', duration: '2 menit', durationSeconds: 120, category: 'Pikiran', color: Color(0xFF0EA5E9), flavorText: 'Imajinasi butuh ruang untuk bernapas.',
  ),
  DailyBoostItem(
    emoji: '🕺', title: 'Joget Bebas 1 Menit', description: 'Putar satu lagu upbeat, gerakkan tubuhmu sebebas mungkin. Buang semua stres!', duration: '1 menit', durationSeconds: 60, category: 'Gerak', color: Color(0xFFF59E0B), flavorText: 'Lepaskan hormon endorfinmu sekarang!',
  ),
  DailyBoostItem(
    emoji: '📝', title: 'Gratitude Journaling', description: 'Tulis satu hal baik yang terjadi di kampus hari ini, sekecil apapun itu.', duration: '2 menit', durationSeconds: 120, category: 'Pikiran', color: Color(0xFF14B8A6), flavorText: 'Selalu ada pelangi setelah hujan revisi.',
  ),
  DailyBoostItem(
    emoji: '👀', title: 'Istirahat Mata 20-20-20', description: 'Lihat objek sejauh 6 meter selama 20 detik setelah 20 menit menatap layar.', duration: '20 detik', durationSeconds: 20, category: 'Mata', color: Color(0xFFF97316), flavorText: 'Matamu adalah aset masa depanmu.',
  ),
  DailyBoostItem(
    emoji: '💤', title: 'Power Nap 10 Menit', description: 'Pejamkan mata sejenak, jangan sampai tertidur lelap. Reset energimu.', duration: '10 menit', durationSeconds: 600, category: 'Pikiran', color: Color(0xFF475569), flavorText: 'Charger tubuhmu sebelum lanjut belajar.',
  ),
];

// ──────────────────────────────────────────────────
// Shared State (Simple)
// ──────────────────────────────────────────────────
class DailyBoostData {
  static final Set<int> doneChallenges = {};
}

// ──────────────────────────────────────────────────
// Main Page
// ──────────────────────────────────────────────────
class DailyBoostPage extends StatefulWidget {
  const DailyBoostPage({super.key});

  @override
  State<DailyBoostPage> createState() => _DailyBoostPageState();
}

class _DailyBoostPageState extends State<DailyBoostPage> with SingleTickerProviderStateMixin {
  String _selectedCategory = 'Semua';
  late AnimationController _headerAnim;
  int _totalPoints = 0;

  final List<String> _categories = ['Semua','Fokus','Gerak','Pernapasan','Peregangan','Pikiran','Segar','Mata'];

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _loadData();
  }

  static const String _dailyBoostDoneIdsKey = 'daily_boost_done_ids';
  static const String _dailyBoostDoneDateKey = 'daily_boost_done_date';

  Future<void> _loadData() async {
    await UserService.fetchCurrentUser();
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final savedDate = prefs.getString(_dailyBoostDoneDateKey) ?? '';
    final savedDone = prefs.getStringList(_dailyBoostDoneIdsKey) ?? [];

    final shouldReset = savedDate != today;
    if (shouldReset) {
      await prefs.setString(_dailyBoostDoneDateKey, today);
      await prefs.setStringList(_dailyBoostDoneIdsKey, []);
    }

    final user = LaravelSessionService.user;
    if (mounted) {
      setState(() {
        DailyBoostData.doneChallenges.clear();
        if (!shouldReset) {
          DailyBoostData.doneChallenges.addAll(savedDone.map(int.parse));
        }

        final rawPoint = user?['point'] ?? 0;
        _totalPoints = rawPoint is int ? rawPoint : int.tryParse(rawPoint.toString()) ?? 0;
      });
    }
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await prefs.setString(_dailyBoostDoneDateKey, today);
    await prefs.setStringList(
      _dailyBoostDoneIdsKey,
      DailyBoostData.doneChallenges.map((id) => id.toString()).toList(),
    );
    await UserService.updateUserPoints(_totalPoints);
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    super.dispose();
  }

  List<DailyBoostItem> get _filtered {
    if (_selectedCategory == 'Semua') return _allDailyBoosts;
    return _allDailyBoosts.where((t) => t.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final doneCount = DailyBoostData.doneChallenges.length;
    final total = _allDailyBoosts.length;
    final progress = total == 0 ? 0.0 : doneCount / total;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            stretch: true,
            backgroundColor: primaryColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [primaryColor, primaryColor.withOpacity(0.85)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
                child: Stack(
                  children: [
                    _buildCircles(),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                 Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Lakukan Progress Misi Hari Ini', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Halo, ${LaravelSessionService.user?['name'] ?? 'Mahasiswa'}', 
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: -0.5)
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.stars_rounded, color: Colors.amber, size: 20),
                                      const SizedBox(width: 6),
                                      Text('$_totalPoints', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white10)),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Progress Misi Hari Ini', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                      Text('$doneCount / $total Selesai', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(value: progress, minHeight: 10, backgroundColor: Colors.white10, valueColor: const AlwaysStoppedAnimation<Color>(Colors.white)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _CategoryHeaderDelegate(
              categories: _categories,
              selected: _selectedCategory,
              onSelect: (cat) => setState(() => _selectedCategory = cat),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final filtered = _filtered;
                  if (index >= filtered.length) return null;
                  final item = filtered[index];
                  final realIndex = _allDailyBoosts.indexOf(item);
                  final isDone = DailyBoostData.doneChallenges.contains(realIndex);
                  return _DailyBoostCard(item: item, isDone: isDone, onTap: () => _showDetail(item, realIndex));
                },
                childCount: _filtered.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircles() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _headerAnim,
        builder: (context, child) {
          return Stack(
            children: [
              Positioned(right: -40 + (_headerAnim.value * 20), top: -30, child: Container(width: 180, height: 180, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle))),
              Positioned(left: -60, bottom: -20 + (_headerAnim.value * 30), child: Container(width: 220, height: 220, decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), shape: BoxShape.circle))),
            ],
          );
        },
      ),
    );
  }

  void _showDetail(DailyBoostItem item, int realIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DailyBoostDetailSheet(
        item: item,
        isDone: DailyBoostData.doneChallenges.contains(realIndex),
        onToggle: () {
          setState(() {
            if (DailyBoostData.doneChallenges.contains(realIndex)) {
              DailyBoostData.doneChallenges.remove(realIndex);
              _totalPoints = (_totalPoints - 50).clamp(0, double.infinity).toInt();
            } else {
              DailyBoostData.doneChallenges.add(realIndex);
              _totalPoints += 50;
            }
          });
          _saveProgress();
        },
      ),
    );
  }
}

class _CategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelect;
  _CategoryHeaderDelegate({required this.categories, required this.selected, required this.onSelect});
  @override double get minExtent => 70;
  @override double get maxExtent => 70;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final primaryColor = Theme.of(context).primaryColor;
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final cat = categories[i];
          final isSelected = cat == selected;
          return GestureDetector(
            onTap: () => onSelect(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected ? [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : [],
              ),
              child: Center(child: Text(cat, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, fontSize: 13))),
            ),
          );
        },
      ),
    );
  }
  @override bool shouldRebuild(_CategoryHeaderDelegate old) => old.selected != selected;
}

class _DailyBoostCard extends StatelessWidget {
  final DailyBoostItem item;
  final bool isDone;
  final VoidCallback onTap;
  const _DailyBoostCard({required this.item, required this.isDone, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: isDone ? item.color.withOpacity(0.4) : Colors.transparent, width: 2), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))]),
        child: Row(
          children: [
            Container(width: 64, height: 64, decoration: BoxDecoration(gradient: LinearGradient(colors: [item.color.withOpacity(0.15), item.color.withOpacity(0.05)]), borderRadius: BorderRadius.circular(20)), child: Center(child: Text(item.emoji, style: const TextStyle(fontSize: 32)))),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDone ? item.color : Colors.grey.shade800)),
                  const SizedBox(height: 6),
                  Text(item.flavorText, style: TextStyle(fontSize: 12, color: Colors.grey.shade400, fontStyle: FontStyle.italic)),
                  const SizedBox(height: 10),
                  Row(children: [_badge(item.color.withOpacity(0.1), item.color, Icons.timer_outlined, item.duration), const SizedBox(width: 8), _badge(Colors.grey.shade50, Colors.grey.shade600, Icons.folder_open_rounded, item.category)]),
                ],
              ),
            ),
            Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: isDone ? item.color : Colors.grey.shade50, shape: BoxShape.circle), child: Icon(isDone ? Icons.check_rounded : Icons.add_rounded, color: isDone ? Colors.white : Colors.grey.shade300, size: 20)),
          ],
        ),
      ),
    );
  }
  Widget _badge(Color bg, Color text, IconData icon, String label) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 12, color: text), const SizedBox(width: 4), Text(label, style: TextStyle(fontSize: 10, color: text, fontWeight: FontWeight.bold))]));
  }
}

class _DailyBoostDetailSheet extends StatefulWidget {
  final DailyBoostItem item;
  final bool isDone;
  final VoidCallback onToggle;
  const _DailyBoostDetailSheet({required this.item, required this.isDone, required this.onToggle});
  @override State<_DailyBoostDetailSheet> createState() => _DailyBoostDetailSheetState();
}

class _DailyBoostDetailSheetState extends State<_DailyBoostDetailSheet> {
  int? _remainingSeconds;
  bool _isRunning = false;
  Timer? _timer;
  final AudioPlayer _alarmPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _alarmPlayer.setReleaseMode(ReleaseMode.stop);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _alarmPlayer.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _remainingSeconds ??= widget.item.durationSeconds;
      _isRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds != null && _remainingSeconds! > 0) {
        setState(() => _remainingSeconds = _remainingSeconds! - 1);
      } else {
        timer.cancel();
        _complete();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  Future<void> _playAlarm() async {
    try {
      await _alarmPlayer.play(UrlSource('https://actions.google.com/sounds/v1/alarms/alarm_clock.ogg'));
    } catch (_) {
      // Ignore if alarm sound fails to play.
    }
  }

  void _complete() {
    if (!widget.isDone) widget.onToggle();
    _playAlarm();
    Navigator.pop(context);
    _showSuccessOverlay();
  }

  void _showSuccessOverlay() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text('Keren! +50 Poin Berhasil Diraih!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
  String _formatTime(int seconds) { final m = (seconds / 60).floor(); final s = seconds % 60; return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'; }
  @override Widget build(BuildContext context) {
    final isStarted = _remainingSeconds != null;
    final primaryColor = Theme.of(context).primaryColor;
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          Stack(alignment: Alignment.center, children: [SizedBox(width: 120, height: 120, child: CircularProgressIndicator(value: isStarted ? (1 - (_remainingSeconds! / widget.item.durationSeconds)) : 0, strokeWidth: 8, backgroundColor: widget.item.color.withOpacity(0.1), valueColor: AlwaysStoppedAnimation<Color>(widget.item.color))), Text(widget.item.emoji, style: const TextStyle(fontSize: 60))]),
          const SizedBox(height: 24),
          Text(widget.item.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Text(widget.item.flavorText, style: TextStyle(fontSize: 14, color: widget.item.color, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Text(widget.item.description, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.grey.shade500, height: 1.5)),
          const SizedBox(height: 24),
          if (isStarted) Text(_formatTime(_remainingSeconds!), style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, letterSpacing: 2, fontFamily: 'monospace')),
          const SizedBox(height: 32),
          widget.isDone
              ? SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.grey.shade700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('Sudah selesai untuk hari ini', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                )
              : !isStarted
                  ? SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _startTimer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 8,
                          shadowColor: primaryColor.withOpacity(0.4),
                        ),
                        child: const Text('MULAI MISI SEKARANG', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 60,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade200),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              child: const Text('Batal', style: TextStyle(color: Colors.black54)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 60,
                            child: ElevatedButton(
                              onPressed: _isRunning ? _pauseTimer : _startTimer,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isRunning ? Colors.amber : Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              child: Text(_isRunning ? 'JEDA MISI' : 'LANJUTKAN', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ],
                    ),
        ],
      ),
    );
  }
}
