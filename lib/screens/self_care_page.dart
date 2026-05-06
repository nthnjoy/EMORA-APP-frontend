import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_service.dart';
import '../services/laravel_session_service.dart';
import '../services/theme_manager.dart';

// ──────────────────────────────────────────────────
// Model
// ──────────────────────────────────────────────────
class SelfCareModule {
  final String title;
  final String subtitle;
  final String content;
  final String icon;
  final int points;
  final String category;
  final Color color;

  const SelfCareModule({
    required this.title,
    required this.subtitle,
    required this.content,
    required this.icon,
    required this.points,
    required this.category,
    required this.color,
  });
}

// ──────────────────────────────────────────────────
// Pool 30 Modul Self-Care
// ──────────────────────────────────────────────────
const List<SelfCareModule> _selfCarePool = [
  SelfCareModule(
    title: 'Mengenal Kesehatan Mental',
    subtitle: 'Dasar-dasar kesejahteraan emosional.',
    content: 'Kesehatan mental adalah keadaan sejahtera di mana individu menyadari potensinya, dapat mengatasi tekanan hidup yang normal, dapat bekerja secara produktif, dan mampu memberikan kontribusi kepada komunitasnya. Ini bukan sekadar tidak adanya gangguan mental.\n\nTips hari ini: Luangkan 5 menit untuk sekadar bernapas dan menyadari apa yang Anda rasakan tanpa menghakimi diri sendiri.',
    icon: '🧠',
    points: 30,
    category: 'Edukasi',
    color: Color(0xFF6366F1),
  ),
  SelfCareModule(
    title: 'Kesehatan Mental Mahasiswa',
    subtitle: 'Tantangan unik di dunia perkuliahan.',
    content: 'Mahasiswa sering menghadapi tekanan akademik, ekspektasi sosial, dan perubahan fase hidup. Menurut penelitian, kecemasan dan stres adalah tantangan paling umum. Menyadari bahwa Anda tidak sendirian adalah langkah pertama menuju pemulihan.\n\nIngat: Nilai ujian tidak mendefinisikan harga diri Anda sebagai manusia.',
    icon: '🎓',
    points: 30,
    category: 'Mahasiswa',
    color: Color(0xFF10B981),
  ),
  SelfCareModule(
    title: 'Cara Menjaga Mental Tetap Terjaga',
    subtitle: 'Strategi praktis untuk hari-hari sibuk.',
    content: 'Menjaga rutinitas tidur, asupan nutrisi yang baik, dan aktivitas fisik ringan sangat berpengaruh pada kestabilan mood. Jangan ragu untuk mengatakan "tidak" pada aktivitas yang menguras energi Anda secara berlebihan.\n\nPrinsip: Self-care is not selfish, it is necessary.',
    icon: '🛡️',
    points: 30,
    category: 'Tips',
    color: Color(0xFFF59E0B),
  ),
  SelfCareModule(
    title: 'Mengelola Stres Akademik',
    subtitle: 'Menghadapi tugas dan ujian dengan tenang.',
    content: 'Stres akademik bisa dikelola dengan teknik manajemen waktu seperti Pomodoro dan membagi tugas besar menjadi langkah-langkah kecil. Jangan biarkan tumpukan tugas membuat Anda lumpuh.\n\nLatihan: Tulis 3 tugas prioritas hari ini saja, lupakan sisanya untuk sementara.',
    icon: '📚',
    points: 30,
    category: 'Manajemen',
    color: Color(0xFFEF4444),
  ),
  SelfCareModule(
    title: 'Mood dan Pengaruh Lingkungan',
    subtitle: 'Bagaimana sekitar kita memengaruhi perasaan.',
    content: 'Warna, pencahayaan, dan orang-orang di sekitar Anda memengaruhi kondisi mental secara bawah sadar. Ruangan yang rapi cenderung memberikan ketenangan pikiran.\n\nAction: Rapikan satu sudut kecil di meja belajarmu sekarang.',
    icon: '🌍',
    points: 30,
    category: 'Mood',
    color: Color(0xFF06B6D4),
  ),
  SelfCareModule(
    title: 'Pentingnya Istirahat Berkualitas',
    subtitle: 'Bukan sekadar tidur, tapi pemulihan.',
    content: 'Otak membutuhkan waktu untuk memproses informasi dan membuang racun sisa metabolisme. Kurang tidur berkorelasi langsung dengan penurunan mood dan fokus.\n\nKomitmen: Matikan layar 30 menit sebelum waktu tidur malam ini.',
    icon: '💤',
    points: 30,
    category: 'Fisik',
    color: Color(0xFF475569),
  ),
  SelfCareModule(
    title: 'Membangun Resiliensi',
    subtitle: 'Bangkit dari kegagalan dan tantangan.',
    content: 'Resiliensi adalah kemampuan untuk beradaptasi dan bangkit kembali dari kesulitan. Ini bisa dilatih dengan mengubah pola pikir dari "Kenapa ini terjadi padaku?" menjadi "Apa yang bisa aku pelajari dari ini?".\n\nAfirmasi: Saya memiliki kekuatan untuk melewati tantangan ini.',
    icon: '🌱',
    points: 30,
    category: 'Mindset',
    color: Color(0xFF8B5CF6),
  ),
  SelfCareModule(
    title: 'Sosialisasi dan Koneksi Manusia',
    subtitle: 'Dukungan sosial sebagai pelindung mental.',
    content: 'Berbicara dengan teman atau orang kepercayaan dapat menurunkan kadar kortisol (hormon stres). Koneksi manusia adalah salah satu prediktor kebahagiaan yang paling kuat.\n\nTugas: Hubungi satu teman lama atau keluarga hanya untuk menyapa.',
    icon: '🤝',
    points: 30,
    category: 'Sosial',
    color: Color(0xFFEC4899),
  ),
  SelfCareModule(
    title: 'Mengenali Tanda Burnout',
    subtitle: 'Kapan harus berhenti sejenak.',
    content: 'Burnout adalah kelelahan emosional, fisik, dan mental akibat stres berkepanjangan. Tandanya termasuk sinisme, rasa tidak kompeten, dan kelelahan kronis.\n\nSaran: Jika Anda merasa burnout, istirahatlah total selama satu hari tanpa rasa bersalah.',
    icon: '🔥',
    points: 30,
    category: 'Peringatan',
    color: Color(0xFFEA580C),
  ),
  SelfCareModule(
    title: 'Mindfulness dalam Keseharian',
    subtitle: 'Hadir sepenuhnya di sini dan saat ini.',
    content: 'Mindfulness berarti memperhatikan momen saat ini tanpa menghakimi. Ini membantu mengurangi kecemasan tentang masa depan dan penyesalan tentang masa lalu.\n\nLatihan: Rasakan tekstur air dan sabun saat Anda mencuci tangan hari ini.',
    icon: '🧘',
    points: 30,
    category: 'Mental',
    color: Color(0xFF14B8A6),
  ),
];

class SelfCarePage extends StatefulWidget {
  final VoidCallback? onBackToDashboard;
  const SelfCarePage({super.key, this.onBackToDashboard});

  @override
  State<SelfCarePage> createState() => _SelfCarePageState();
}

class _SelfCarePageState extends State<SelfCarePage> {
  final Set<int> _completedModules = {};
  int _totalPoints = 0;
  List<SelfCareModule> _todayModules = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await UserService.fetchCurrentUser();
    await _loadSavedProgress();
    _checkDailyReset();
  }

  void _checkDailyReset() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month}-${now.day}";
    final lastReset = prefs.getString('self_care_last_reset') ?? "";

    if (lastReset != todayStr) {
      setState(() {
        _completedModules.clear();
        final pool = List<SelfCareModule>.from(_selfCarePool)..shuffle();
        _todayModules = pool.take(5).toList();
      });
      await prefs.setString('self_care_last_reset', todayStr);
      await prefs.setStringList('self_care_completed_modules', []);
      final moduleIndices = _todayModules.map((m) => _selfCarePool.indexOf(m).toString()).toList();
      await prefs.setStringList('self_care_current_modules', moduleIndices);
    } else {
      final savedIndices = prefs.getStringList('self_care_current_modules') ?? [];
      if (savedIndices.isEmpty) {
        final pool = List<SelfCareModule>.from(_selfCarePool)..shuffle();
        _todayModules = pool.take(5).toList();
      } else {
        _todayModules = savedIndices.map((idx) => _selfCarePool[int.parse(idx)]).toList();
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _loadSavedProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final savedModules = prefs.getStringList('self_care_completed_modules') ?? [];
    
    final sessionUser = LaravelSessionService.user;
    final sessionPoints = sessionUser != null ? (sessionUser['point'] ?? 0) : 0;
    int backendPoints = sessionPoints is int ? sessionPoints : int.tryParse(sessionPoints.toString()) ?? 0;

    if (!mounted) return;

    setState(() {
      _completedModules.clear();
      _completedModules.addAll(savedModules.map(int.parse));
      _totalPoints = backendPoints;
    });
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('self_care_completed_modules', _completedModules.map((idx) => idx.toString()).toList());
    await UserService.updateUserPoints(_totalPoints);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              widget.onBackToDashboard?.call();
            }
          },
        ),
        title: Text('Self-Care', style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 20, color: Colors.white)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.stars_rounded, size: 18, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text('$_totalPoints', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Modul Kesehatan Mental',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pelajari cara menjaga kesehatan mentalmu dengan membaca modul harian.',
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  _buildProgressBanner(),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final module = _todayModules[index];
                  final globalIndex = _selfCarePool.indexOf(module);
                  final isDone = _completedModules.contains(globalIndex);
                  
                  return _buildModuleCard(module, globalIndex, isDone);
                },
                childCount: _todayModules.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildProgressBanner() {
    final done = _completedModules.length;
    final total = _todayModules.length;
    final progress = total == 0 ? 0.0 : done / total;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progres Membaca', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
              Text('$done / $total Selesai', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(SelfCareModule module, int globalIndex, bool isDone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8)),
        ],
        border: isDone ? Border.all(color: module.color.withOpacity(0.3), width: 2) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _showModuleContent(module, globalIndex, isDone),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: module.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(child: Text(module.icon, style: const TextStyle(fontSize: 30))),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        module.title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDone ? Colors.grey : Colors.black87,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        module.subtitle,
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isDone)
                  const Icon(Icons.check_circle, color: Colors.green, size: 28)
                else
                  const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showModuleContent(SelfCareModule module, int globalIndex, bool isDone) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(32),
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                module.icon,
                style: const TextStyle(fontSize: 64),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                module.title,
                style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, height: 1.2),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                module.subtitle,
                style: GoogleFonts.poppins(fontSize: 16, color: module.color, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 32),
              Text(
                module.content,
                style: GoogleFonts.poppins(fontSize: 16, height: 1.8, color: Colors.black87),
              ),
              const SizedBox(height: 48),
              if (!isDone)
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: module.color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      setState(() {
                        _completedModules.add(globalIndex);
                        _totalPoints += module.points;
                      });
                      _saveProgress();
                      Navigator.pop(context);
                      _showSuccessSnackBar(module.points);
                    },
                    child: Text('SELESAI MEMBACA (+${module.points} Pts)', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(int pts) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selamat! Kamu mendapatkan $pts poin.'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
