import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool notificationsEnabled = true;
  TimeOfDay selectedTime = const TimeOfDay(hour: 8, minute: 30);

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadSettings();
  }

  Future<void> _initializeNotifications() async {
    await NotificationService().init();
    await NotificationService().requestPermissions();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      final hour = prefs.getInt('notification_hour') ?? 8;
      final minute = prefs.getInt('notification_minute') ?? 30;
      selectedTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  Future<void> _saveSettings() async {
    // Ensure notifications initialized
    await NotificationService().init();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', notificationsEnabled);
    await prefs.setInt('notification_hour', selectedTime.hour);
    await prefs.setInt('notification_minute', selectedTime.minute);
    
    if (notificationsEnabled) {
      await NotificationService().scheduleDailyNotification(selectedTime);
    } else {
      await NotificationService().cancelAll();
    }
  }

  Future<void> _pickTime() async {
    final primaryColor = Theme.of(context).primaryColor;
    
    int tempHour = selectedTime.hour;
    int tempMinute = selectedTime.minute;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              height: 400,
              child: Column(
                children: [
                  Text(
                    'Pilih Waktu Pengingat',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Geser untuk mengatur jam dan menit',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Jam
                        _buildPickerColumn(
                          count: 24,
                          initialValue: tempHour,
                          onChanged: (val) => tempHour = val,
                          label: 'Jam',
                        ),
                        Text(':', style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: primaryColor)),
                        // Menit
                        _buildPickerColumn(
                          count: 60,
                          initialValue: tempMinute,
                          onChanged: (val) => tempMinute = val,
                          label: 'Menit',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedTime = TimeOfDay(hour: tempHour, minute: tempMinute);
                        });
                        _saveSettings();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Pengingat diatur untuk pukul ${selectedTime.format(context)}'),
                            backgroundColor: primaryColor,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Text('Simpan Waktu', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPickerColumn({
    required int count,
    required int initialValue,
    required ValueChanged<int> onChanged,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey)),
          Expanded(
            child: ListWheelScrollView.useDelegate(
              itemExtent: 50,
              perspective: 0.005,
              diameterRatio: 1.2,
              physics: const FixedExtentScrollPhysics(),
              controller: FixedExtentScrollController(initialItem: initialValue),
              onSelectedItemChanged: onChanged,
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: count,
                builder: (context, index) {
                  return Center(
                    child: Text(
                      index.toString().padLeft(2, '0'),
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        title: Text('Pengaturan Notifikasi', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(primaryColor),
              const SizedBox(height: 32),
              Text(
                'Preferensi Pengingat',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              _buildSettingTile(
                icon: Icons.notifications_active_outlined,
                title: 'Aktifkan Pengingat',
                subtitle: 'Dapatkan motivasi harian dari EMORA',
                trailing: Switch.adaptive(
                  value: notificationsEnabled,
                  activeColor: primaryColor,
                  onChanged: (value) {
                    setState(() => notificationsEnabled = value);
                    _saveSettings();
                  },
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingTile(
                icon: Icons.access_time_rounded,
                title: 'Waktu Pengingat',
                subtitle: 'Notifikasi akan muncul setiap pukul ${selectedTime.format(context)}',
                onTap: notificationsEnabled ? _pickTime : null,
                trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400),
              ),
              const SizedBox(height: 24),
              _buildInfoSection(primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 32),
          const SizedBox(height: 16),
          Text(
            'Tetap Konsisten',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Atur pengingat harian agar EMORA bisa membantumu menjaga kesehatan mental secara rutin.',
            style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.9), fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        ),
        title: Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600)),
        trailing: trailing,
      ),
    );
  }

  Widget _buildInfoSection(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Catatan',
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: primaryColor),
                ),
                const SizedBox(height: 4),
                Text(
                  'Notifikasi akan muncul sebagai popup di layar handphone-mu meskipun aplikasi sedang tertutup.',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
