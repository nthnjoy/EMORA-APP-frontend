import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/mood_service.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  late Future<Map<String, dynamic>> _futureMoods;

  @override
  void initState() {
    super.initState();
    _futureMoods = MoodService.fetchMoods();
  }

  void _reload() {
    setState(() {
      _futureMoods = MoodService.fetchMoods();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistik Mood"),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureMoods,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!['success'] != true) {
            final message = snapshot.data?['message']?.toString() ??
                'Gagal memuat statistik mood.';
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _reload,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data!['data'];
          final List<Map<String, dynamic>> moods = data is List
              ? data
                  .whereType<Map>()
                  .map((item) => Map<String, dynamic>.from(item))
                  .toList()
              : <Map<String, dynamic>>[];

          if (moods.isEmpty) {
            return const Center(child: Text('Belum ada data mood.'));
          }

          final moodCount = <String, int>{
            "senang": 0,
            "marah": 0,
            "sedih": 0,
            "takut": 0,
            "biasa": 0,
            "terkejut": 0,
            "jijik": 0,
          };

          for (final mood in moods) {
            final label = (mood['mood_label'] ?? '').toString().toLowerCase();
            if (moodCount.containsKey(label)) {
              moodCount[label] = moodCount[label]! + 1;
            }
          }

          final pieSections = moodCount.entries
              .where((entry) => entry.value > 0)
              .map(
                (entry) => PieChartSectionData(
                  value: entry.value.toDouble(),
                  title: '${entry.key}\n${entry.value}',
                  radius: 90,
                ),
              )
              .toList();

          if (pieSections.isEmpty) {
            return const Center(child: Text('Belum ada data mood valid.'));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 32,
                sections: pieSections,
              ),
            ),
          );
        },
      ),
    );
  }
}
