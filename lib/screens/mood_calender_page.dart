import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/mood_service.dart';
import 'package:intl/intl.dart';

class MoodCalendarPage extends StatefulWidget {
  const MoodCalendarPage({super.key});

  @override
  State<MoodCalendarPage> createState() => _MoodCalendarPageState();
}

class _MoodCalendarPageState extends State<MoodCalendarPage> with TickerProviderStateMixin {
  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();

  bool isLoading = true;
  String? loadError;

  Map<DateTime, Color> dailyMoodColors = {};
  Map<DateTime, double> dailyAverageScore = {};
  Map<DateTime, String> dailyCategory = {};
  Map<DateTime, List<Map<String, dynamic>>> dailyMoodDocs = {};

  @override
  void initState() {
    super.initState();
    fetchMoodData();
  }

  DateTime cleanDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime? parseDate(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty) return null;
    return DateTime.tryParse(text)?.toLocal();
  }

  int convertToScore(int code) {
    switch (code) {
      case 1: return 7; // senang
      case 2: return 2; // marah
      case 3: return 5; // sedih
      case 4: return 4; // takut
      case 5: return 6; // biasa
      case 6: return 3; // terkejut
      case 7: return 1; // jijik
      default: return 5;
    }
  }

  int convertMoodLabelToCode(String moodLabel) {
    switch (moodLabel.toLowerCase()) {
      case 'senang': return 1;
      case 'marah': return 2;
      case 'sedih': return 3;
      case 'takut': return 4;
      case 'biasa': return 5;
      case 'terkejut':
      case 'kaget': return 6;
      case 'jijik': return 7;
      default: return 5;
    }
  }

  Color getColorFromAverage(double avg) {
    if (avg >= 6.5) return const Color(0xFF10B981); // Emerald
    if (avg >= 5) return const Color(0xFF3B82F6);   // Blue
    if (avg >= 3.5) return const Color(0xFFF59E0B); // Amber
    return const Color(0xFFEF4444);                 // Red
  }

  String getCategory(double avg) {
    if (avg >= 6.5) return "Sangat Baik";
    if (avg >= 5) return "Stabil";
    if (avg >= 3.5) return "Waspada";
    return "Bahaya";
  }

  IconData getMoodIcon(String label) {
    switch (label.toLowerCase()) {
      case 'senang': return Icons.sentiment_very_satisfied_rounded;
      case 'marah': return Icons.sentiment_very_dissatisfied_rounded;
      case 'sedih': return Icons.sentiment_dissatisfied_rounded;
      case 'takut': return Icons.wb_cloudy_rounded;
      case 'biasa': return Icons.sentiment_neutral_rounded;
      case 'terkejut': return Icons.wb_incandescent_rounded;
      case 'jijik': return Icons.sick_rounded;
      default: return Icons.face_rounded;
    }
  }

  Future<void> fetchMoodData() async {
    setState(() {
      isLoading = true;
      loadError = null;
    });

    final result = await MoodService.fetchMoods();
    if (result['success'] != true) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        loadError = (result['message'] ?? 'Gagal mengambil data mood').toString();
      });
      return;
    }

    final rawData = result['data'];
    final List<Map<String, dynamic>> moods = rawData is List
        ? rawData.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList()
        : <Map<String, dynamic>>[];

    final Map<DateTime, List<int>> tempScores = {};
    final Map<DateTime, List<Map<String, dynamic>>> tempDocs = {};

    for (final mood in moods) {
      final dateTime = parseDate(mood['recorded_at'] ?? mood['created_at']);
      if (dateTime == null) continue;

      final date = cleanDate(dateTime);
      final code = mood['emosi_kode'] is num
          ? (mood['emosi_kode'] as num).toInt()
          : int.tryParse((mood['emosi_kode'] ?? '').toString()) ??
              convertMoodLabelToCode((mood['mood_label'] ?? '').toString());

      final score = convertToScore(code);

      tempScores.putIfAbsent(date, () => []);
      tempDocs.putIfAbsent(date, () => []);
      tempScores[date]!.add(score);
      tempDocs[date]!.add(mood);
    }

    final Map<DateTime, Color> colorMap = {};
    final Map<DateTime, double> avgMap = {};
    final Map<DateTime, String> categoryMap = {};

    tempScores.forEach((date, scores) {
      final avg = scores.reduce((a, b) => a + b) / scores.length;
      avgMap[date] = avg;
      colorMap[date] = getColorFromAverage(avg);
      categoryMap[date] = getCategory(avg);
    });

    if (!mounted) return;
    setState(() {
      isLoading = false;
      dailyMoodColors = colorMap;
      dailyAverageScore = avgMap;
      dailyCategory = categoryMap;
      dailyMoodDocs = tempDocs;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedClean = cleanDate(selectedDay);
    final selectedEntries = dailyMoodDocs[selectedClean] ?? [];
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Riwayat Mood",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.black87, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: fetchMoodData,
            icon: Icon(Icons.refresh_rounded, color: primaryColor),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : Column(
              children: [
                _buildCalendarSection(primaryColor),
                Expanded(
                  child: _buildDetailsSection(selectedEntries, selectedClean, primaryColor),
                ),
              ],
            ),
    );
  }

  Widget _buildCalendarSection(Color primaryColor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: TableCalendar(
          focusedDay: focusedDay,
          firstDay: DateTime(2020),
          // Batasi lastDay ke hari ini — tanggal masa depan tidak bisa dipilih
          lastDay: DateTime.now(),
          rowHeight: 52,
          selectedDayPredicate: (day) => isSameDay(selectedDay, day),
          // Tanggal yang boleh dipilih: hanya hari ini dan sebelumnya
          enabledDayPredicate: (day) {
            final today = cleanDate(DateTime.now());
            final d    = cleanDate(day);
            return !d.isAfter(today);
          },
          onPageChanged: (focused) {
            // Jangan lewat melampaui bulan saat ini
            final now = DateTime.now();
            if (focused.year > now.year ||
                (focused.year == now.year && focused.month > now.month)) {
              return;
            }
            setState(() => focusedDay = focused);
          },
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16),
            leftChevronIcon: Icon(Icons.chevron_left_rounded, color: primaryColor),
            // Sembunyikan panah kanan jika sudah di bulan saat ini
            rightChevronIcon: () {
              final now = DateTime.now();
              final isCurrentMonth = focusedDay.year == now.year &&
                  focusedDay.month == now.month;
              return Icon(
                Icons.chevron_right_rounded,
                color: isCurrentMonth
                    ? Colors.grey.shade300
                    : primaryColor,
              );
            }(),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontWeight: FontWeight.w600, fontSize: 12),
            weekendStyle: GoogleFonts.poppins(color: Colors.red.shade200, fontWeight: FontWeight.w600, fontSize: 12),
          ),
          onDaySelected: (selected, focused) {
            // Double-check: jangan proses kalau tanggal masa depan
            final today = cleanDate(DateTime.now());
            if (cleanDate(selected).isAfter(today)) return;
            setState(() {
              selectedDay = selected;
              focusedDay  = focused;
            });
          },
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            todayTextStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
            selectedDecoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: primaryColor.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))
              ],
            ),
            defaultTextStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            weekendTextStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.red.shade300),
            outsideDaysVisible: false,
            // Styling untuk tanggal yang disabled (future dates)
            disabledTextStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade300,
            ),
            disabledDecoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
          ),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, _) {
              final clean = cleanDate(day);
              if (dailyMoodColors.containsKey(clean)) {
                final moodColor = dailyMoodColors[clean]!;
                return Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: moodColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: moodColor, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${day.day}',
                    style: GoogleFonts.poppins(
                      color: moodColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }
              return null;
            },
            // Builder khusus untuk tanggal yang di-disable (masa depan)
            disabledBuilder: (context, day, _) {
              return Container(
                margin: const EdgeInsets.all(8),
                alignment: Alignment.center,
                child: Text(
                  '${day.day}',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade300,
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsSection(List<Map<String, dynamic>> entries, DateTime date, Color primaryColor) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 30, 30, 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE, d MMMM').format(date),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${entries.length} Catatan Mood',
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade400, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                if (dailyAverageScore.containsKey(date))
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: dailyMoodColors[date]!.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: dailyMoodColors[date], shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Text(
                          dailyCategory[date]!,
                          style: GoogleFonts.poppins(
                            color: dailyMoodColors[date],
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (loadError != null)
            Expanded(child: _buildErrorState(primaryColor))
          else
            Expanded(
              child: entries.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                      physics: const BouncingScrollPhysics(),
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        return _buildMoodCard(entries[index]);
                      },
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Color primaryColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 64),
            const SizedBox(height: 20),
            Text(loadError!, textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.black54)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: fetchMoodData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Coba Lagi"),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(color: Colors.grey.shade50, shape: BoxShape.circle),
              child: Icon(Icons.calendar_today_rounded, size: 64, color: Colors.grey.shade200),
            ),
            const SizedBox(height: 24),
            Text(
              "Belum ada catatan mood",
              style: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              "Catat perasaanmu hari ini di Dashboard!",
              style: GoogleFonts.poppins(color: Colors.grey.shade300, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodCard(Map<String, dynamic> mood) {
    final label = (mood['mood_label'] ?? 'biasa').toString();
    final note = (mood['note'] ?? '').toString();
    final feeling = (mood['perasaan'] ?? '').toString();
    final time = parseDate(mood['recorded_at'] ?? mood['created_at']);
    
    final color = getColorFromAverage(convertToScore(
      mood['emosi_kode'] is num ? (mood['emosi_kode'] as num).toInt() : 5
    ).toDouble());

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.shade50),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(width: 6, height: 120, color: color),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                              child: Icon(getMoodIcon(label), color: color, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              label.toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w800,
                                color: color,
                                fontSize: 14,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        if (time != null)
                          Text(
                            DateFormat('HH:mm').format(time),
                            style: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                      ],
                    ),
                    if (feeling.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.favorite_rounded, size: 16, color: Colors.pinkAccent),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              feeling,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (note.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.notes_rounded, size: 14, color: Colors.grey.shade400),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                note,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.black54,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
