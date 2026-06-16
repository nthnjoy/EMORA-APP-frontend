import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'counselor_notification_service.dart';

/// Service tunggal yang menggabungkan dua sumber badge notifikasi:
/// 1. Pesan konselor yang belum dibaca  (dari CounselorNotificationService)
/// 2. Alarm harian yang sudah tiba      (dilacak via SharedPreferences)
///
/// Dengarkan [totalBadge] untuk mendapat jumlah badge gabungan.
class NotificationBadgeService {
  static final NotificationBadgeService _instance =
      NotificationBadgeService._internal();
  factory NotificationBadgeService() => _instance;
  NotificationBadgeService._internal();

  // ── State ──────────────────────────────────────────────────────────────────
  final ValueNotifier<int> totalBadge = ValueNotifier<int>(0);

  /// Apakah alarm harian sudah tiba dan belum dibuka oleh user.
  final ValueNotifier<int> alarmBadge = ValueNotifier<int>(0);

  Timer? _alarmCheckTimer;

  // ── Inisialisasi ───────────────────────────────────────────────────────────
  void init() {
    // Langsung hitung badge saat dipanggil
    _recalculate();

    // Dengarkan perubahan pesan konselor
    CounselorNotificationService().unreadCount.addListener(_recalculate);

    // Cek alarm setiap menit
    _alarmCheckTimer?.cancel();
    _alarmCheckTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkAlarmArrived(),
    );
    // Cek sekarang juga
    _checkAlarmArrived();
  }

  void dispose() {
    _alarmCheckTimer?.cancel();
    CounselorNotificationService().unreadCount.removeListener(_recalculate);
  }

  // ── Pengecekan alarm harian ────────────────────────────────────────────────
  /// Cek apakah waktu alarm harian sudah tercapai hari ini dan
  /// user belum membuka halaman notifikasi.
  Future<void> _checkAlarmArrived() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool('notifications_enabled') ?? false;
      if (!enabled) {
        alarmBadge.value = 0;
        _recalculate();
        return;
      }

      final hour   = prefs.getInt('notification_hour')   ?? 8;
      final minute = prefs.getInt('notification_minute') ?? 30;

      final now     = DateTime.now();
      final alarmDt = DateTime(now.year, now.month, now.day, hour, minute);

      // Tanggal terakhir user melihat halaman notifikasi
      final lastSeenStr = prefs.getString('notification_last_seen') ?? '';
      final lastSeenDate = lastSeenStr.isNotEmpty
          ? DateTime.tryParse(lastSeenStr)
          : null;

      final today = DateTime(now.year, now.month, now.day);

      // Alarm sudah tiba hari ini jika: now >= alarmDt DAN
      // belum pernah dilihat hari ini
      final alarmTodayArrived = now.isAfter(alarmDt) || now.isAtSameMomentAs(alarmDt);
      final seenToday = lastSeenDate != null &&
          DateTime(lastSeenDate.year, lastSeenDate.month, lastSeenDate.day)
              .isAtSameMomentAs(today);

      alarmBadge.value = (alarmTodayArrived && !seenToday) ? 1 : 0;
      _recalculate();
    } catch (_) {}
  }

  // ── Dipanggil saat user membuka halaman Notification ──────────────────────
  Future<void> markNotificationPageOpened() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'notification_last_seen',
        DateTime.now().toIso8601String(),
      );
      alarmBadge.value = 0;
      _recalculate();
    } catch (_) {}
  }

  // ── Hitung ulang badge total ───────────────────────────────────────────────
  void _recalculate() {
    final counselor = CounselorNotificationService().unreadCount.value;
    final alarm     = alarmBadge.value;
    totalBadge.value = counselor + alarm;
  }

  /// Paksa refresh: berguna setelah halaman Notification dibuka/ditutup.
  Future<void> refresh() async {
    await _checkAlarmArrived();
    _recalculate();
  }
}
