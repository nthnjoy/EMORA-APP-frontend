import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  static const List<Map<String, dynamic>> recommendations = [
    {
      'id': 'senang',
      'label': 'Senang',
      'icon': Icons.sentiment_very_satisfied_rounded,
      'color': Color(0xFF10B981),
      'activity': 'Bernyanyi atau menari sebentar untuk menjaga energi positif.',
      'quote': 'Kebahagiaan adalah energi yang menular!'
    },
    {
      'id': 'marah',
      'label': 'Marah',
      'icon': Icons.sentiment_very_dissatisfied_rounded,
      'color': Color(0xFFEF4444),
      'activity': 'Lakukan latihan peregangan atau jalan singkat untuk melepas ketegangan.',
      'quote': 'Tenangkan pikiran, lepaskan beban.'
    },
    {
      'id': 'sedih',
      'label': 'Sedih',
      'icon': Icons.sentiment_dissatisfied_rounded,
      'color': Color(0xFF3B82F6),
      'activity': 'Dengarkan musik relaksasi dan tulis hal yang kamu syukuri.',
      'quote': 'Setiap air mata punya cerita, setiap senyum punya harapan.'
    },
    {
      'id': 'takut',
      'label': 'Takut',
      'icon': Icons.wb_cloudy_rounded,
      'color': Color(0xFFF59E0B),
      'activity': 'Coba tarik napas dalam-dalam sambil duduk tenang selama satu menit.',
      'quote': 'Keberanian bukan berarti tidak takut, tapi terus melangkah.'
    },
    {
      'id': 'biasa',
      'label': 'Biasa',
      'icon': Icons.sentiment_neutral_rounded,
      'color': Color(0xFF64748B),
      'activity': 'Ambil waktu satu menit untuk fokus pada pernapasan dan bersyukur.',
      'quote': 'Ketenangan adalah kunci kejernihan pikiran.'
    },
    {
      'id': 'terkejut',
      'label': 'Terkejut',
      'icon': Icons.wb_incandescent_rounded,
      'color': Color(0xFF8B5CF6),
      'activity': 'Saatkan satu menit untuk merenungi apa yang terjadi dan tenangkan diri.',
      'quote': 'Jadikan kejutan sebagai pelajaran berharga.'
    },
    {
      'id': 'jijik',
      'label': 'Jijik',
      'icon': Icons.sick_rounded,
      'color': Color(0xFF06B6D4),
      'activity': 'Bergerak ringan atau buat minuman hangat untuk menenangkan tubuh.',
      'quote': 'Beri ruang untuk kenyamanan dirimu.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Rekomendasi Aktivitas',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.black87, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          physics: const BouncingScrollPhysics(),
          itemCount: recommendations.length,
          itemBuilder: (context, index) {
            final item = recommendations[index];
            final color = item['color'] as Color;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: color, width: 6),
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(item['icon'] as IconData, color: color, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            item['label'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item['activity'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '"${item['quote']}"',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
