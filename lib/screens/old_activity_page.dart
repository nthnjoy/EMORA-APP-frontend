import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/activity_service.dart';

class OldActivityPage extends StatelessWidget {
  const OldActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final activities = ActivityService.getActivities();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Aktivitas (V1 - Klasik)',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final act = activities[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: act.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(act.icon, color: act.color),
              ),
              title: Text(
                act.title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                act.subtitle,
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, color: Colors.black26),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => act.targetView(context)),
              ),
            ),
          );
        },
      ),
    );
  }
}
