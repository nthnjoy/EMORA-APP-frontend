import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'activity_page.dart';
import 'old_activity_page.dart';
import 'new_activity_feature_page.dart';

class ActivityHubPage extends StatelessWidget {
  const ActivityHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              'EVOLUSI WELLNESS',
              style: GoogleFonts.orbitron(
                fontSize: 14,
                letterSpacing: 4,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Pilih Pengalaman Aktivitas',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildVersionCard(
                    context,
                    title: 'V1 - KLASIK',
                    subtitle: 'Tampilan bersih, sederhana, dan fokus pada daftar aktivitas.',
                    icon: Icons.list_alt_rounded,
                    color: Colors.blue,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OldActivityPage())),
                  ),
                  const SizedBox(height: 20),
                  _buildVersionCard(
                    context,
                    title: 'V2 - BIO-HACKER',
                    subtitle: 'Gamifikasi futuristik untuk meningkatkan keterikatan pengguna.',
                    icon: Icons.bolt_rounded,
                    color: Colors.cyanAccent,
                    isDark: true,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivityPage())),
                  ),
                  const SizedBox(height: 20),
                  _buildVersionCard(
                    context,
                    title: 'V3 - ZEN HORIZON',
                    subtitle: 'Pengalaman premium imersif dengan desain glassmorphism.',
                    icon: Icons.auto_awesome_rounded,
                    color: Colors.amber,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewActivityFeaturePage())),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Gunakan halaman ini untuk membandingkan iterasi desain kepada dosen pembimbing.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 10, color: Colors.black38),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isDark = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.orbitron(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isDark ? Colors.white24 : Colors.black12,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
