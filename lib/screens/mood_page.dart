import 'package:flutter/material.dart';
import '../services/mood_service.dart';
import 'feeling_page.dart';

class MoodPage extends StatefulWidget {
  const MoodPage({super.key});

  @override
  State<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends State<MoodPage> {
  String? selectedMood;
  String? selectedFeeling;
  bool isSavingMood = false;

  final List<Map<String, dynamic>> moods = [
    {
      'emoji': '😊',
      'label': 'Senang',
      'textColor': const Color(0xFFF4A300),
      'borderColor': const Color(0xFFF4A300),
      'bgColor': const Color(0xFFFFF4CC),
    },
    {
      'emoji': '😡',
      'label': 'Marah',
      'textColor': const Color(0xFFFF4D00),
      'borderColor': const Color(0xFFFF4D00),
      'bgColor': const Color(0xFFFFD9D1),
    },
    {
      'emoji': '😢',
      'label': 'Sedih',
      'textColor': const Color(0xFF3366FF),
      'borderColor': const Color(0xFF3366FF),
      'bgColor': const Color(0xFFE3EBFF),
    },
    {
      'emoji': '😨',
      'label': 'Takut',
      'textColor': const Color(0xFF8E44FF),
      'borderColor': const Color(0xFF8E44FF),
      'bgColor': const Color(0xFFEBDFFF),
    },
    {
      'emoji': '😐',
      'label': 'Biasa',
      'textColor': const Color(0xFF37474F),
      'borderColor': const Color(0xFF37474F),
      'bgColor': const Color(0xFFE5E5E5),
    },
    {
      'emoji': '😱',
      'label': 'Terkejut',
      'textColor': const Color(0xFFFF6A00),
      'borderColor': const Color(0xFFFF6A00),
      'bgColor': const Color(0xFFFFE3D1),
    },
    {
      'emoji': '🤢',
      'label': 'Jijik',
      'textColor': const Color(0xFF5E8C00),
      'borderColor': const Color(0xFF5E8C00),
      'bgColor': const Color(0xFFDCE9C7),
    },
  ];

  Future<void> goToFeelingPage(String mood) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => FeelingPage(selectedMood: mood)),
    );

    if (result != null) {
      setState(() {
        selectedMood = mood;
        selectedFeeling = result;
      });

      await saveMoodSelection();
    }
  }

  int _moodCodeFromLabel(String moodLabel) {
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
        return 6;
      case 'jijik':
        return 7;
      default:
        return 5;
    }
  }

  Future<void> saveMoodSelection() async {
    if (selectedMood == null || selectedFeeling == null) {
      return;
    }

    setState(() => isSavingMood = true);

    final result = await MoodService.createMood(
      moodLabel: selectedMood!,
      feeling: selectedFeeling!,
      emotionCode: _moodCodeFromLabel(selectedMood!),
      note: null,
      title: null,
    );

    if (!mounted) {
      return;
    }

    setState(() => isSavingMood = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mood berhasil disimpan ke MongoDB')),
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Gagal menyimpan mood')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Mood'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bagaimana suasana hatimu?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Pilih satu mood yang paling sesuai dengan perasaanmu saat ini.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 16,
                children: moods.map((mood) {
                  return GestureDetector(
                    onTap: () => goToFeelingPage(mood['label']),
                    child: Container(
                      width: 100,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: mood['bgColor'],
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: mood['borderColor'],
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            mood['emoji'],
                            style: const TextStyle(fontSize: 40),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            mood['label'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: mood['textColor'],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (selectedMood != null && selectedFeeling != null) ...[
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pilihan Kamu:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Mood: $selectedMood',
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Perasaan: $selectedFeeling',
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Sedang disimpan otomatis...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
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
    );
  }
}

