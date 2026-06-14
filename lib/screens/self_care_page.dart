import 'dart:async';
import 'dart:convert';
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
  int _selectedTab = 0; // 0 for Modules, 1 for Daily Activities
  Map<String, List<dynamic>> _dailyActivities = {};

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await UserService.fetchCurrentUser();
    await _fetchModulesFromApi();
    await _loadSavedProgress();
    await _loadDailyActivities();
  }

  Future<void> _fetchModulesFromApi() async {
    try {
      final response = await UserService.fetchModules();
      if (response['success'] && response['data'] != null) {
        final List<dynamic> data = response['data'];
        if (mounted) {
          setState(() {
            try {
              _allModules =
                  data.map((json) => SelfCareModule.fromJson(json)).toList();
              _todayModules = List<SelfCareModule>.from(_allModules);
            } catch (e, stack) {
              _errorMessage = 'Error parsing data: $e';
            }
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = response['message'] ?? 'Gagal memuat API';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Network error: $e';
          _isLoading = false;
        });
      }
    }
  }

  String get _userStorageSuffix {
    final user = LaravelSessionService.user;
    final identifier = user?['id']?.toString() ??
        user?['nim']?.toString() ??
        user?['username']?.toString() ??
        user?['email']?.toString() ??
        'guest';
    return identifier.replaceAll(RegExp(r'[^A-Za-z0-9_]'), '_').toLowerCase();
  }

  String get _selfCareCompletedModulesKey => 'self_care_completed_modules_ids_$_userStorageSuffix';
  String get _selfCareDailyActivitiesKey => 'self_care_daily_activities_$_userStorageSuffix';

  Future<void> _loadSavedProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final savedModules =
        prefs.getStringList(_selfCareCompletedModulesKey) ?? [];

    final sessionUser = LaravelSessionService.user;
    final sessionPoints =
        sessionUser != null ? (sessionUser['point'] ?? 0) : 0;
    int backendPoints = sessionPoints is int
        ? sessionPoints
        : int.tryParse(sessionPoints.toString()) ?? 0;
        
    final backendCompletedModules = (sessionUser?['completed_modules'] as List?)
        ?.map((e) => e.toString())
        .toList() ?? [];

    if (!mounted) return;

    setState(() {
      _completedModules.clear();
      _completedModules.addAll(savedModules);
      _completedModules.addAll(backendCompletedModules);
      _totalPoints = backendPoints;
    });
  }

  Future<void> _saveProgress(String? newModuleId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _selfCareCompletedModulesKey, _completedModules.toList());
    await UserService.updateUserPoints(_totalPoints, moduleId: newModuleId);
  }

  Future<void> _handleRefresh() async {
    setState(() => _isLoading = true);
    await _initializeData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text('Modul dan poin berhasil diperbarui.',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ],
          ),
          backgroundColor: Colors.blue.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _loadDailyActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final String? rawJson = prefs.getString(_selfCareDailyActivitiesKey);
    if (rawJson != null) {
      try {
        final decoded = jsonDecode(rawJson);
        if (decoded is Map<String, dynamic>) {
          setState(() {
            _dailyActivities = decoded.map((key, value) {
              return MapEntry(key, List<dynamic>.from(value));
            });
          });
        }
      } catch (e) {
        debugPrint('Error loading daily activities: $e');
      }
    }
  }

  Future<void> _recordDailyActivity(SelfCareModule module) async {
    final prefs = await SharedPreferences.getInstance();
    final String todayStr = DateTime.now().toIso8601String().substring(0, 10);
    
    final String? rawJson = prefs.getString(_selfCareDailyActivitiesKey);
    Map<String, dynamic> activities = {};
    if (rawJson != null) {
      try {
        activities = jsonDecode(rawJson);
      } catch (e) {
        debugPrint('Error decoding daily activities: $e');
      }
    }
    
    List<dynamic> todayList = activities[todayStr] ?? [];
    
    bool alreadyExists = todayList.any((item) {
      if (item is Map) {
        return item['id'] == module.id;
      }
      return false;
    });
    
    if (!alreadyExists) {
      todayList.add({
        'id': module.id,
        'title': module.title,
        'timestamp': DateTime.now().toIso8601String(),
        'points': module.points,
        'category': module.category,
      });
      activities[todayStr] = todayList;
      await prefs.setString(_selfCareDailyActivitiesKey, jsonEncode(activities));
      await _loadDailyActivities();
    }
  }

  String _formatIndonesianDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length != 3) return dateStr;
      final year = parts[0];
      final month = parts[1];
      final day = int.tryParse(parts[2])?.toString() ?? parts[2];
      
      const months = {
        '01': 'Januari',
        '02': 'Februari',
        '03': 'Maret',
        '04': 'April',
        '05': 'Mei',
        '06': 'Juni',
        '07': 'Juli',
        '08': 'Agustus',
        '09': 'September',
        '10': 'Oktober',
        '11': 'November',
        '12': 'Desember',
      };
      
      final monthName = months[month] ?? month;
      
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      if (dateStr == todayStr) {
        return 'Hari ini';
      }
      
      final yesterdayStr = DateTime.now().subtract(const Duration(days: 1)).toIso8601String().substring(0, 10);
      if (dateStr == yesterdayStr) {
        return 'Kemarin';
      }
      
      return '$day $monthName $year';
    } catch (e) {
      return dateStr;
    }
  }

  /// Dipanggil oleh ModuleReaderPage setelah scroll selesai
  Future<void> _onModuleCompleted(SelfCareModule module) async {
    if (_completedModules.contains(module.id)) return;
    setState(() {
      _completedModules.add(module.id);
      _totalPoints += module.points;
    });
    await _saveProgress(module.id);
    await _recordDailyActivity(module);
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
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.poppins(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : _todayModules.isEmpty
                  ? Center(
                  child: Text(
                    'Tidak ada modul tersedia saat ini.',
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _handleRefresh,
                  color: primaryColor,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
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
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Container(
                            height: 52,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => setState(() => _selectedTab = 0),
                                    borderRadius: BorderRadius.circular(12),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 250),
                                      curve: Curves.easeInOut,
                                      decoration: BoxDecoration(
                                        color: _selectedTab == 0 ? Colors.white : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: _selectedTab == 0
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.05),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                )
                                              ]
                                            : [],
                                      ),
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.menu_book_rounded,
                                            size: 18,
                                            color: _selectedTab == 0 ? primaryColor : Colors.grey,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Modul',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: _selectedTab == 0 ? primaryColor : Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => setState(() => _selectedTab = 1),
                                    borderRadius: BorderRadius.circular(12),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 250),
                                      curve: Curves.easeInOut,
                                      decoration: BoxDecoration(
                                        color: _selectedTab == 1 ? Colors.white : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: _selectedTab == 1
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.05),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                )
                                              ]
                                            : [],
                                      ),
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.history_toggle_off_rounded,
                                            size: 18,
                                            color: _selectedTab == 1 ? primaryColor : Colors.grey,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Aktivitas Harian',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: _selectedTab == 1 ? primaryColor : Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (_selectedTab == 0)
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        )
                      else
                        _buildDailyActivitiesSliver(primaryColor),
                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  ),
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

  Widget _buildDailyActivitiesSliver(Color primaryColor) {
    if (_dailyActivities.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  size: 64,
                  color: primaryColor.withOpacity(0.4),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Belum Ada Aktivitas',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Yuk, baca modul kesehatan mental hari ini untuk melatih self-care dan menambah poin!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final sortedDates = _dailyActivities.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final dateStr = sortedDates[index];
            final modulesList = _dailyActivities[dateStr] ?? [];
            final count = modulesList.length;

            return Container(
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      color: primaryColor.withOpacity(0.05),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 16,
                                color: primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatIndonesianDate(dateStr),
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$count Modul Dibaca',
                              style: GoogleFonts.poppins(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: List.generate(count, (idx) {
                          final item = modulesList[idx];
                          final title = item['title'] ?? '-';
                          final category = item['category'] ?? '-';
                          final points = item['points'] ?? 0;
                          final timestamp = item['timestamp'] != null
                              ? DateTime.tryParse(item['timestamp'].toString())
                              : null;
                          final timeStr = timestamp != null
                              ? '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}'
                              : '';

                          return Column(
                            children: [
                              if (idx > 0)
                                const Divider(
                                  height: 24,
                                  thickness: 0.5,
                                  color: Color(0xFFE2E8F0),
                                ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.check_rounded,
                                      color: Colors.green.shade600,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            color: const Color(0xFF1E293B),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              category,
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                color: Colors.grey.shade500,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            if (timeStr.isNotEmpty) ...[
                                              const SizedBox(width: 8),
                                              Icon(
                                                Icons.access_time_rounded,
                                                size: 10,
                                                color: Colors.grey.shade400,
                                              ),
                                              const SizedBox(width: 3),
                                              Text(
                                                timeStr,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 10,
                                                  color: Colors.grey.shade400,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.stars_rounded,
                                        size: 12,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '+$points',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          childCount: sortedDates.length,
        ),
      ),
    );
  }
}
