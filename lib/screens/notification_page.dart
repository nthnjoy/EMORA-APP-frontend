import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool notificationsEnabled = true;
  TimeOfDay selectedTime = const TimeOfDay(hour: 20, minute: 0);

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (time != null) {
      setState(() {
        selectedTime = time;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                title: const Text('Aktifkan pengingat aplikasi'),
                value: notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    notificationsEnabled = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Waktu notifikasi'),
                subtitle: Text('${selectedTime.format(context)}'),
                trailing: IconButton(
                  onPressed: notificationsEnabled ? _pickTime : null,
                  icon: const Icon(Icons.access_time),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Pengingat',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Aplikasi akan mengingatkanmu untuk mencatat mood, cerita, atau aktivitas pada waktu yang dipilih.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
