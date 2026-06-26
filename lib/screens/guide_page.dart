import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class _GuideSection {
  final String heading;
  final List<_GuideItem> items;
  const _GuideSection({required this.heading, required this.items});
}

class _GuideItem {
  final String title;
  final String description;
  final IconData icon;
  const _GuideItem({
    required this.title,
    required this.description,
    required this.icon,
  });
}

const List<_GuideSection> _guideSections = [
  _GuideSection(
    heading: 'Dashboard',
    items: [
      _GuideItem(
        title: 'Mood Summary',
        description:
            'Menampilkan ringkasan emosional kamu selama 14 hari terakhir dengan emoji yang menyesuaikan kondisi emosional-mu.',
        icon: Icons.mood_rounded,
      ),
      _GuideItem(
        title: 'Mood & Feeling',
        description:
            'Gunakan halaman ini untuk mencatat suasana hati dan perasaan yang sedang kamu alami setiap harinya.',
        icon: Icons.favorite_rounded,
      ),
      _GuideItem(
        title: 'Story Corner',
        description:
            'Gunakan halaman ini untuk menuliskan cerita, pengalaman, atau hal-hal yang sedang kamu rasakan dalam bentuk jurnal pribadi.',
        icon: Icons.auto_stories_rounded,
      ),
      _GuideItem(
        title: 'Streak',
        description:
            'Menampilkan jumlah hari kamu mencatat suasana hati selama menggunakan aplikasi. Streak akan bertambah apabila kamu melakukan pencatatan setiap hari. Jika tidak mencatat selama satu hari, streak akan terhenti dan ikon api akan padam.',
        icon: Icons.local_fire_department_rounded,
      ),
      _GuideItem(
        title: 'Daily Boost',
        description:
            'Berisi berbagai aktivitas singkat yang dapat membantu meningkatkan suasana hati kamu. Kamu juga akan memperoleh poin setelah berhasil menyelesaikan aktivitas yang tersedia.',
        icon: Icons.bolt_rounded,
      ),
      _GuideItem(
        title: 'Quotes',
        description:
            'Menampilkan kutipan motivasi yang disesuaikan dengan suasana hati terakhir yang kamu pilih.',
        icon: Icons.format_quote_rounded,
      ),
      _GuideItem(
        title: 'Music',
        description:
            'Menyediakan pilihan musik yang dapat kamu dengarkan sesuai dengan suasana hati saat ini.',
        icon: Icons.music_note_rounded,
      ),
      _GuideItem(
        title: 'Notification',
        description:
            'Gunakan halaman ini untuk mengatur jadwal notifikasi pengingat harian sesuai dengan waktu yang kamu tentukan.',
        icon: Icons.notifications_rounded,
      ),
    ],
  ),
  _GuideSection(
    heading: 'Self-Care',
    items: [
      _GuideItem(
        title: 'Modul Kesehatan Emosional',
        description:
            'Halaman Self Care menyediakan berbagai informasi dan materi mengenai kesehatan emosional. Modul yang tersedia dipilih dan disusun oleh konselor. Kamu akan memperoleh poin setelah membaca dan menyelesaikan modul.',
        icon: Icons.extension_rounded,
      ),
    ],
  ),
  _GuideSection(
    heading: 'History',
    items: [
      _GuideItem(
        title: 'Riwayat Mood',
        description:
            'Pada halaman Kalender, kamu dapat melihat riwayat suasana hati dan perasaan yang telah dicatat selama menggunakan Emolens.',
        icon: Icons.calendar_month_rounded,
      ),
    ],
  ),
  _GuideSection(
    heading: 'Profile',
    items: [
      _GuideItem(
        title: 'Theme',
        description:
            'Kamu dapat membeli dan menggunakan berbagai tema tampilan dengan menukarkan poin yang telah dikumpulkan.',
        icon: Icons.palette_rounded,
      ),
      _GuideItem(
        title: 'Point',
        description:
            'Poin merupakan hadiah yang dapat diperoleh dengan menyelesaikan aktivitas pada halaman Daily Boost dan membaca modul pada halaman Self Care.',
        icon: Icons.stars_rounded,
      ),
    ],
  ),
];

class GuidePage extends StatelessWidget {
  const GuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final isDark  = Theme.of(context).brightness == Brightness.dark;

    final bgColor   = isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final textDark  = isDark ? Colors.white.withOpacity(0.9) : const Color(0xFF1E293B);
    final textMuted = isDark ? Colors.white.withOpacity(0.5) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Panduan Aplikasi',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(36),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
              
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      size: 42,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Guide Book',
                    style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Panduan lengkap penggunaan fitur Emolens',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.75),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.checklist_rounded, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          '${_guideSections.expand((s) => s.items).length} Fitur Dijelaskan',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, secIndex) {
                  final section = _guideSections[secIndex];
                  return _SectionCard(
                    section: section,
                    primary: primary,
                    cardColor: cardColor,
                    textDark: textDark,
                    textMuted: textMuted,
                    sectionIndex: secIndex,
                  );
                },
                childCount: _guideSections.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final _GuideSection section;
  final Color primary;
  final Color cardColor;
  final Color textDark;
  final Color textMuted;
  final int sectionIndex;

  const _SectionCard({
    required this.section,
    required this.primary,
    required this.cardColor,
    required this.textDark,
    required this.textMuted,
    required this.sectionIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
   
        Row(
          children: [
            Container(
              width: 4,
              height: 22,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              section.heading,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

       
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: List.generate(section.items.length, (i) {
              final item = section.items[i];
              final isLast = i == section.items.length - 1;
              return _GuideItemTile(
                item: item,
                primary: primary,
                textDark: textDark,
                textMuted: textMuted,
                isLast: isLast,
                itemIndex: i,
              );
            }),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _GuideItemTile extends StatefulWidget {
  final _GuideItem item;
  final Color primary;
  final Color textDark;
  final Color textMuted;
  final bool isLast;
  final int itemIndex;

  const _GuideItemTile({
    required this.item,
    required this.primary,
    required this.textDark,
    required this.textMuted,
    required this.isLast,
    required this.itemIndex,
  });

  @override
  State<_GuideItemTile> createState() => _GuideItemTileState();
}

class _GuideItemTileState extends State<_GuideItemTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.vertical(
            top: widget.itemIndex == 0 ? const Radius.circular(24) : Radius.zero,
            bottom: widget.isLast && !_expanded ? const Radius.circular(24) : Radius.zero,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: widget.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.item.icon,
                    color: widget.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),

                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.title,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: widget.textDark,
                        ),
                      ),
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 250),
                        firstChild: const SizedBox.shrink(),
                        secondChild: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            widget.item.description,
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              color: widget.textMuted,
                              height: 1.6,
                            ),
                          ),
                        ),
                        crossFadeState: _expanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                
                AnimatedRotation(
                  duration: const Duration(milliseconds: 250),
                  turns: _expanded ? 0.5 : 0,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: widget.primary.withOpacity(0.6),
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        if (!widget.isLast)
          Divider(
            height: 1,
            thickness: 0.5,
            indent: 72,
            endIndent: 18,
            color: Colors.grey.withOpacity(0.15),
          ),
      ],
    );
  }
}
