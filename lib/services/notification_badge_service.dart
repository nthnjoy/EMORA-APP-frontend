import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'counselor_notification_service.dart';

class NotificationBadgeService {
  static final NotificationBadgeService _instance =
      NotificationBadgeService._internal();
  factory NotificationBadgeService() => _instance;
  NotificationBadgeService._internal();

  
  final ValueNotifier<int> totalBadge = ValueNotifier<int>(0);

  
  final ValueNotifier<int> alarmBadge = ValueNotifier<int>(0);

  Timer? _alarmCheckTimer;

  
  void init() {
    
    _recalculate();

    
    CounselorNotificationService().unreadCount.addListener(_recalculate);

    
    _alarmCheckTimer?.cancel();
    _alarmCheckTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkAlarmArrived(),
    );
    
    _checkAlarmArrived();
  }

  void dispose() {
    _alarmCheckTimer?.cancel();
    CounselorNotificationService().unreadCount.removeListener(_recalculate);
  }

  
  
  
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

      
      final lastSeenStr = prefs.getString('notification_last_seen') ?? '';
      final lastSeenDate = lastSeenStr.isNotEmpty
          ? DateTime.tryParse(lastSeenStr)
          : null;

      final today = DateTime(now.year, now.month, now.day);

      
      
      final alarmTodayArrived = now.isAfter(alarmDt) || now.isAtSameMomentAs(alarmDt);
      final seenToday = lastSeenDate != null &&
          DateTime(lastSeenDate.year, lastSeenDate.month, lastSeenDate.day)
              .isAtSameMomentAs(today);

      alarmBadge.value = (alarmTodayArrived && !seenToday) ? 1 : 0;
      _recalculate();
    } catch (_) {}
  }

  
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

  
  void _recalculate() {
    final counselor = CounselorNotificationService().unreadCount.value;
    final alarm     = alarmBadge.value;
    totalBadge.value = counselor + alarm;
  }

  
  Future<void> refresh() async {
    await _checkAlarmArrived();
    _recalculate();
  }
}
