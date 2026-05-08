import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_service.dart';
import '../services/laravel_session_service.dart';
import 'module_reader_page.dart';


// ──────────────────────────────────────────────────
// Model
// ──────────────────────────────────────────────────
class SelfCareModule {
  final String id;
  final String title;
  final String subtitle;
  final String content;
  final String icon;
  final int points;
  final String category;
  final Color color;
  final String? contentUrl;
  final String? thumbnailUrl;

  const SelfCareModule({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.icon,
    required this.points,
    required this.category,
    required this.color,
    this.contentUrl,
    this.thumbnailUrl,
  });

  factory SelfCareModule.fromJson(Map<String, dynamic> json) {
    return SelfCareModule(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      content: json['content'] ?? '',
      icon: json['icon'] ?? '',
      points: json['points'] is int
          ? json['points']
          : int.tryParse(json['points'].toString()) ?? 0,
      category: json['category'] ?? '',
      color: Color(
          int.parse((json['color'] ?? '0xFF6366F1').toString())),
      contentUrl: json['content_url'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
    );
  }
}

class SelfCarePage extends StatefulWidget {
  final VoidCallback? onBackToDashboard;
  const SelfCarePage({super.key, this.onBackToDashboard});

  @override
  State<SelfCarePage> createState() => _SelfCarePageState();
}

class _SelfCarePageState extends State<SelfCarePage> {
  final Set<String> _completedModules = {};
  int _totalPoints = 0;
  List<SelfCareModule> _allModules = [];
  List<SelfCareModule> _todayModules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await UserService.fetchCurrentUser();
    await _fetchModulesFromApi();
    await _loadSavedProgress();
  }

  Future<void> _fetchModulesFromApi() async {
    final response = await UserService.fetchModules();
    if (response['success'] && response['data'] != null) {
      final List<dynamic> data = response['data'];
      if (mounted) {
        setState(() {
          _allModules =
              data.map((json) => SelfCareModule.fromJson(json)).toList();
          _todayModules = List<SelfCareModule>.from(_allModules);
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadSavedProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final savedModules =
        prefs.getStringList('self_care_completed_modules_ids') ?? [];

    final sessionUser = LaravelSessionService.user;
    final sessionPoints =
        sessionUser != null ? (sessionUser['point'] ?? 0) : 0;
    int backendPoints = sessionPoints is int
        ? sessionPoints
        : int.tryParse(sessionPoints.toString()) ?? 0;

    if (!mounted) return;

    setState(() {
      _completedModules.clear();
      _completedModules.addAll(savedModules);
      _totalPoints = backendPoints;
    });
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'self_care_completed_modules_ids', _completedModules.toList());
    await UserService.updateUserPoints(_totalPoints);
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Progres?', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Status "Sudah Baca" pada semua modul akan dihapus. Kamu bisa membaca ulang semuanya dari awal.', style: GoogleFonts.poppins()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('self_care_completed_modules_ids');
      setState(() {
        _completedModules.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Progres berhasil direset.'), backgroundColor: Colors.blue),
        );
      }
    }
  }

  /// Dipanggil oleh ModuleReaderPage setelah scroll selesai
  Future<void> _onModuleCompleted(SelfCareModule module) async {
    if (_completedModules.contains(module.id)) return;
    setState(() {
      _completedModules.add(module.id);
      _totalPoints += module.points;
    });
    await _saveProgress();
    if (mounted) _showSuccessSnackBar(module.points);
  }

  void _openModuleReader(SelfCareModule module) {
    final isDone = _completedModules.contains(module.id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ModuleReaderPage(
          args: ModuleReaderArgs(
            id: module.id,
            title: module.title,
            subtitle: module.subtitle,
            content: module.content,
            icon: module.icon,
            points: module.points,
            color: module.color,
            thumbnailUrl: module.thumbnailUrl,
            contentUrl: module.contentUrl,
            alreadyCompleted: isDone,
          ),
          onCompleted: () => _onModuleCompleted(module),
        ),
      ),
    );
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              widget.onBackToDashboard?.call();
            }
          },
        ),
        title: Text('Self-Care',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70, size: 20),
            tooltip: 'Reset Progress Membaca',
            onPressed: () => _confirmReset(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.stars_rounded,
                        size: 18, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text('$_totalPoints',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : _todayModules.isEmpty
              ? Center(
                  child: Text(
                    'Tidak ada modul tersedia saat ini.',
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                )
              : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(32)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Modul Kesehatan Mental',
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Pelajari cara menjaga kesehatan mentalmu.\nScroll sampai bawah pada setiap modul untuk mendapat poin.',
                              style: GoogleFonts.poppins(
                                  color: Colors.white70, fontSize: 13),
                            ),
                            const SizedBox(height: 24),
                            _buildProgressBanner(),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final module = _todayModules[index];
                            final isDone =
                                _completedModules.contains(module.id);
                            return _buildModuleCard(module, isDone);
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
              Text('Progres Membaca',
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              Text('$done / $total Selesai',
                  style: GoogleFonts.poppins(
                      color: Colors.white70, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white10,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(SelfCareModule module, bool isDone) {
    final hasThumbnail =
        module.thumbnailUrl != null && module.thumbnailUrl!.isNotEmpty;
    final hasContentUrl =
        module.contentUrl != null && module.contentUrl!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
        border: isDone
            ? Border.all(color: module.color.withOpacity(0.3), width: 2)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _openModuleReader(module),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Thumbnail (jika ada) ──────────────────────────────────
              if (hasThumbnail)
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Stack(
                    children: [
                      Image.network(
                        module.thumbnailUrl!,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                          height: 140,
                          color: module.color.withOpacity(0.1),
                          child: Center(
                              child: Text(module.icon,
                                  style:
                                      const TextStyle(fontSize: 48))),
                        ),
                      ),
                      // Badge selesai di atas gambar
                      if (isDone)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade500,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 14),
                                const SizedBox(width: 4),
                                Text('Selesai',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      // Badge PDF
                      if (hasContentUrl)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.shade600,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.picture_as_pdf_rounded,
                                    color: Colors.white, size: 12),
                                const SizedBox(width: 4),
                                Text('PDF',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

              // ─── Info bawah kartu ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Icon (fallback jika tidak ada thumbnail)
                    if (!hasThumbnail)
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: module.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                            child: Text(module.icon,
                                style: const TextStyle(fontSize: 28))),
                      ),
                    if (!hasThumbnail) const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            module.title,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDone
                                  ? Colors.grey
                                  : const Color(0xFF1E293B),
                              decoration: isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            module.subtitle,
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              // Category chip
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color:
                                      module.color.withOpacity(0.1),
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: Text(
                                  module.category,
                                  style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: module.color,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              const Spacer(),
                              // Poin
                              Row(
                                children: [
                                  Icon(Icons.stars_rounded,
                                      size: 14,
                                      color: isDone
                                          ? Colors.grey
                                          : Colors.amber),
                                  const SizedBox(width: 2),
                                  Text(
                                    '+${module.points}',
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isDone
                                            ? Colors.grey
                                            : Colors.amber.shade700),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isDone
                          ? Icons.check_circle_rounded
                          : Icons.arrow_forward_ios_rounded,
                      color: isDone ? Colors.green : Colors.grey,
                      size: isDone ? 26 : 16,
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

  void _showSuccessSnackBar(int pts) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.stars_rounded, color: Colors.amber),
            const SizedBox(width: 8),
            Text('Selamat! Kamu mendapatkan $pts poin.',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
