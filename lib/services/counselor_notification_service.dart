import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:emolens_app/main.dart' show navigatorKey;
import 'api_config.dart';
import 'laravel_session_service.dart';
import 'theme_manager.dart';

class CounselorNotificationService {
  static final CounselorNotificationService _instance =
      CounselorNotificationService._internal();
  factory CounselorNotificationService() => _instance;
  CounselorNotificationService._internal();

  Timer? _timer;
  final Set<String> _shownIds = {};
  bool _isDialogOpen = false;

  /// Jumlah pesan konselor yang belum dibaca. Listen ke ini untuk badge di dashboard.
  final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);

  void startPolling() {
    _timer?.cancel();
    _checkNotifications();
    // Cek setiap 30 detik agar tidak membebani server
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkNotifications();
    });
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _checkNotifications() async {
    if (!LaravelSessionService.isAuthenticated) return;
    if (_isDialogOpen) return;

    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.notificationsUrl),
            headers: _headers(),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        if (parsed['success'] == true && parsed['data'] is List) {
          final list = parsed['data'] as List;

          unreadCount.value = list.length;

          for (var item in list) {
            if (item is Map<String, dynamic>) {
              final id = item['id']?.toString() ?? '';
              final message = item['pesan']?.toString() ?? '';

              if (id.isNotEmpty && !_shownIds.contains(id)) {
                _shownIds.add(id);
                _showAwesomeNotificationDialog(id, message);
                break; // Tampilkan satu pesan pada satu waktu
              }
            }
          }
        }
      } 
      // Jika 404 atau lainnya, kita abaikan saja diam-diam agar tidak spam log
      // Kemungkinan Ngrok belum stabil atau server mati sementara.
    } catch (e) {
      // Abaikan error jaringan diam-diam agar terminal bersih
    }
  }

  /// Ambil semua notifikasi untuk ditampilkan di halaman Notifikasi.
  Future<List<Map<String, dynamic>>> fetchForPage() async {
    if (!LaravelSessionService.isAuthenticated) {
      throw Exception('Belum login / tidak terautentikasi.');
    }
    
    final response = await http
        .get(
          Uri.parse(ApiConfig.notificationsUrl),
          headers: _headers(),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);
      if (parsed['success'] == true && parsed['data'] is List) {
        final list = (parsed['data'] as List)
            .whereType<Map<String, dynamic>>()
            .toList();
        unreadCount.value = list.length;
        return list;
      }
    }
    
    throw Exception('Error dari server: HTTP ${response.statusCode}\nBody: ${response.body}');
  }

  /// Tandai notifikasi sebagai sudah dibaca.
  Future<bool> markNotificationRead(String id) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.markNotificationReadUrl(id)),
            headers: _headers(),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        if (parsed['success'] == true) {
          _shownIds.add(id);
          if (unreadCount.value > 0) {
            unreadCount.value = unreadCount.value - 1;
          }
          return true;
        }
      }
    } catch (e) {
      // Abaikan error
    }
    return false;
  }

  void _showAwesomeNotificationDialog(String id, String message) {
    final context = navigatorKey.currentContext;
    if (context == null) {
      _shownIds.remove(id);
      return;
    }

    _isDialogOpen = true;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        final primaryColor = ThemeManager().primaryColor;

        return PopScope(
          canPop: false,
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            ),
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon Lonceng / Pesan Animasi
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: child,
                        );
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryColor, primaryColor.withOpacity(0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.support_agent_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Panggilan Konseling!',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Konselor EMORA ingin berbicara denganmu.',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: primaryColor.withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.format_quote_rounded, color: primaryColor.withOpacity(0.5), size: 30),
                          const SizedBox(height: 8),
                          Text(
                            message,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey.shade600,
                              side: BorderSide(color: Colors.grey.shade300),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              _isDialogOpen = false;
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Nanti',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shadowColor: primaryColor.withOpacity(0.5),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () async {
                              await markNotificationRead(id);
                              _isDialogOpen = false;
                              Navigator.of(context).pop();
                              _checkNotifications(); // Cek lagi kalau ada pesan lain
                            },
                            child: Text(
                              'Mengerti',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Map<String, String> _headers() {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      // Bypass halaman peringatan interstitial Ngrok
      'ngrok-skip-browser-warning': 'true',
    };
    final authHeader = LaravelSessionService.authorizationHeader;
    if (authHeader != null) {
      headers['Authorization'] = authHeader;
    }
    return headers;
  }
}
