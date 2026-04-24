import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/mood_service.dart';

class MoodCalendarPage extends StatefulWidget {
  const MoodCalendarPage({super.key});

  @override
  State<MoodCalendarPage> createState() => _MoodCalendarPageState();
}

class _MoodCalendarPageState extends State<MoodCalendarPage> {
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
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();
    if (text.isEmpty) {
      return null;
    }

    return DateTime.tryParse(text)?.toLocal();
  }

  int convertToScore(int code) {
    switch (code) {
      case 1:
        return 7; // senang
      case 2:
        return 2; // marah
      case 3:
        return 5; // sedih
      case 4:
        return 4; // takut
      case 5:
        return 6; // biasa
      case 6:
        return 3; // terkejut
      case 7:
        return 1; // jijik
      default:
        return 5;
    }
  }

  int convertMoodLabelToCode(String moodLabel) {
    switch (moodLabel.toLowerCase()) {
      case 'senang':
        return 1;
      case 'marah':
        return 2;
      case 'sedih':
        return 3;
      case 'takut':
        return 4;
      case 'biasa':
        return 5;
      case 'terkejut':
      case 'kaget':
        return 6;
      case 'jijik':
        return 7;
      default:
        return 5;
    }
  }

  Color getColorFromAverage(double avg) {
    if (avg >= 6.5) return Colors.green;
    if (avg >= 5) return Colors.blue;
    if (avg >= 3.5) return Colors.orange;
    return Colors.red;
  }

  String getCategory(double avg) {
    if (avg >= 6.5) return "Sangat Baik";
    if (avg >= 5) return "Stabil";
    if (avg >= 3.5) return "Waspada";
    return "Bahaya";
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
        dailyMoodColors = {};
        dailyAverageScore = {};
        dailyCategory = {};
        dailyMoodDocs = {};
      });
      return;
    }

    final rawData = result['data'];
    final List<Map<String, dynamic>> moods = rawData is List
        ? rawData
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList()
        : <Map<String, dynamic>>[];

    final Map<DateTime, List<int>> tempScores = {};
    final Map<DateTime, List<Map<String, dynamic>>> tempDocs = {};

    for (final mood in moods) {
      final dateTime = parseDate(mood['recorded_at'] ?? mood['created_at']);
      if (dateTime == null) {
        continue;
      }

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

  void showEditDialog(Map<String, dynamic> mood) {
    final moodId = (mood['id'] ?? '').toString();
    if (moodId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID mood tidak valid')),
      );
      return;
    }

    final noteController = TextEditingController(
      text: (mood['note'] ?? '').toString(),
    );
    String selectedMood = (mood['mood_label'] ?? 'biasa').toString().toLowerCase();
    const allowedMoodValues = {
      'senang',
      'marah',
      'sedih',
      'takut',
      'biasa',
      'terkejut',
      'jijik',
    };
    if (selectedMood.trim().isEmpty || !allowedMoodValues.contains(selectedMood)) {
      selectedMood = 'biasa';
    }

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Edit Mood"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedMood,
                items: const [
                  DropdownMenuItem(value: "senang", child: Text("Senang")),
                  DropdownMenuItem(value: "marah", child: Text("Marah")),
                  DropdownMenuItem(value: "sedih", child: Text("Sedih")),
                  DropdownMenuItem(value: "takut", child: Text("Takut")),
                  DropdownMenuItem(value: "biasa", child: Text("Biasa")),
                  DropdownMenuItem(value: "terkejut", child: Text("Terkejut")),
                  DropdownMenuItem(value: "jijik", child: Text("Jijik")),
                ],
                onChanged: (val) {
                  if (val != null) {
                    selectedMood = val;
                  }
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: "Catatan"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await MoodService.updateMood(
                  moodId: moodId,
                  moodLabel: selectedMood,
                  emotionCode: convertMoodLabelToCode(selectedMood),
                  feeling: (mood['perasaan'] ?? '').toString(),
                  title: (mood['title'] ?? '').toString(),
                  note: noteController.text.trim(),
                );

                if (!mounted) return;
                Navigator.pop(context);

                if (result['success'] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mood berhasil diperbarui')),
                  );
                  fetchMoodData();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        (result['message'] ?? 'Gagal memperbarui mood').toString(),
                      ),
                    ),
                  );
                }
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedClean = cleanDate(selectedDay);
    final selectedEntries = dailyMoodDocs[selectedClean] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Mood"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TableCalendar(
                  focusedDay: focusedDay,
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2035),
                  selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                  onDaySelected: (selected, focused) {
                    setState(() {
                      selectedDay = selected;
                      focusedDay = focused;
                    });
                  },
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, _) {
                      final clean = cleanDate(day);
                      if (dailyMoodColors.containsKey(clean)) {
                        return Container(
                          margin: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: dailyMoodColors[clean],
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 10),
                if (loadError != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Text(
                          loadError!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: fetchMoodData,
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  )
                else if (dailyAverageScore.containsKey(selectedClean))
                  Column(
                    children: [
                      Text(
                        "Rata-rata: ${dailyAverageScore[selectedClean]!.toStringAsFixed(2)}",
                      ),
                      Text("Kategori: ${dailyCategory[selectedClean]}"),
                    ],
                  )
                else
                  const Text('Belum ada data mood di tanggal ini'),
                const Divider(),
                Expanded(
                  child: selectedEntries.isEmpty
                      ? const Center(child: Text('Tidak ada catatan mood'))
                      : ListView.builder(
                          itemCount: selectedEntries.length,
                          itemBuilder: (context, index) {
                            final mood = selectedEntries[index];
                            final moodLabel =
                                (mood['mood_label'] ?? '').toString().toUpperCase();
                            final note = (mood['note'] ?? '').toString();
                            final feeling = (mood['perasaan'] ?? '').toString();

                            return ListTile(
                              title: Text(moodLabel),
                              subtitle: Text(
                                [
                                  if (feeling.isNotEmpty) 'Perasaan: $feeling',
                                  if (note.isNotEmpty) note,
                                ].join('\n'),
                              ),
                              trailing: const Icon(Icons.edit),
                              onTap: () => showEditDialog(mood),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
