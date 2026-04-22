import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';

class MoodCalendarPage extends StatefulWidget {
  const MoodCalendarPage({super.key});

  @override
  State<MoodCalendarPage> createState() => _MoodCalendarPageState();
}

class _MoodCalendarPageState extends State<MoodCalendarPage> {
  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();

  Map<DateTime, Color> dailyMoodColors = {};
  Map<DateTime, double> dailyAverageScore = {};
  Map<DateTime, String> dailyCategory = {};
  Map<DateTime, List<QueryDocumentSnapshot>> dailyMoodDocs = {};

  @override
  void initState() {
    super.initState();
    fetchMoodData();
  }

  // ===== CLEAN DATE =====
  DateTime cleanDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // ===== SCORE MAPPING =====
  int convertToScore(int code) {
    switch (code) {
      case 1: return 7; // senang
      case 2: return 2; // marah
      case 3: return 5; // sedih
      case 4: return 4; // takut
      case 5: return 6; // biasa
      case 6: return 3; // kaget
      case 7: return 1; // jijik
      default: return 5;
    }
  }

  // ===== WARNA =====
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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('moods')
        .where('userId', isEqualTo: user.uid)
        .get();

    Map<DateTime, List<int>> tempScores = {};
    Map<DateTime, List<QueryDocumentSnapshot>> tempDocs = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final timestamp = data['createdAt'] as Timestamp?;

      if (timestamp == null) continue;

      DateTime date = cleanDate(timestamp.toDate());
      int score = convertToScore(data['emosi_kode'] ?? 0);

      tempScores.putIfAbsent(date, () => []);
      tempDocs.putIfAbsent(date, () => []);

      tempScores[date]!.add(score);
      tempDocs[date]!.add(doc);
    }

    Map<DateTime, Color> colorMap = {};
    Map<DateTime, double> avgMap = {};
    Map<DateTime, String> categoryMap = {};

    tempScores.forEach((date, scores) {
      double avg = scores.reduce((a, b) => a + b) / scores.length;

      avgMap[date] = avg;
      colorMap[date] = getColorFromAverage(avg);
      categoryMap[date] = getCategory(avg);
    });

    setState(() {
      dailyMoodColors = colorMap;
      dailyAverageScore = avgMap;
      dailyCategory = categoryMap;
      dailyMoodDocs = tempDocs;
    });
  }

  // ===== EDIT MOOD =====
  void showEditDialog(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    TextEditingController noteController =
        TextEditingController(text: data['note'] ?? "");

    String selectedMood = data['mood_label'] ?? "biasa";

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
                  DropdownMenuItem(value: "kaget", child: Text("Kaget")),
                  DropdownMenuItem(value: "jijik", child: Text("Jijik")),
                ],
                onChanged: (val) => selectedMood = val!,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: "Catatan",
                ),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('moods')
                    .doc(doc.id)
                    .update({
                  'mood_label': selectedMood,
                  'note': noteController.text,
                });

                if (mounted) {
                  Navigator.pop(context);
                  fetchMoodData();
                }
              },
              child: const Text("Simpan"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime selectedClean = cleanDate(selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Mood"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: focusedDay,
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            selectedDayPredicate: (day) =>
                isSameDay(selectedDay, day),
            onDaySelected: (selected, focused) {
              setState(() {
                selectedDay = selected;
                focusedDay = focused;
              });
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, _) {
                DateTime clean = cleanDate(day);

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

          if (dailyAverageScore.containsKey(selectedClean))
            Column(
              children: [
                Text(
                  "Rata-rata: ${dailyAverageScore[selectedClean]!.toStringAsFixed(2)}",
                ),
                Text(
                  "Kategori: ${dailyCategory[selectedClean]}",
                ),
              ],
            ),

          const Divider(),

          Expanded(
            child: ListView(
              children: (dailyMoodDocs[selectedClean] ?? [])
                  .map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return ListTile(
                  title: Text(
                    (data['mood_label'] ?? "").toString().toUpperCase(),
                  ),
                  subtitle: Text(data['note'] ?? ""),
                  trailing: const Icon(Icons.edit),
                  onTap: () => showEditDialog(doc),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}