import 'package:flutter/material.dart';

class QuotesPage extends StatelessWidget {
  final List<Map<String, dynamic>> moods;
  final List<Map<String, dynamic>> stories;

  const QuotesPage({super.key, required this.moods, required this.stories});

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty) return null;
    return DateTime.tryParse(text)?.toLocal();
  }

  Map<String, dynamic>? _latestMoodEntry() {
    final sorted = moods.where((item) {
      return (item['recorded_at'] ?? item['created_at']) != null;
    }).toList();

    sorted.sort((a, b) {
      final da = _parseDate(a['recorded_at'] ?? a['created_at']);
      final db = _parseDate(b['recorded_at'] ?? b['created_at']);
      if (da == null || db == null) return 0;
      return db.compareTo(da);
    });

    if (sorted.isEmpty) {
      return null;
    }

    return Map<String, dynamic>.from(sorted.first);
  }

  int _scoreFromCode(int code) {
    switch (code) {
      case 1:
        return 7;
      case 2:
        return 2;
      case 3:
        return 5;
      case 4:
        return 4;
      case 5:
        return 6;
      case 6:
        return 3;
      case 7:
        return 1;
      default:
        return 5;
    }
  }

  int _codeFromLabel(String moodLabel) {
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

  double _calculateScore(Map<String, dynamic> mood) {
    final codeValue = mood['emosi_kode'];
    int code;
    if (codeValue is num) {
      code = codeValue.toInt();
    } else {
      code = _codeFromLabel((mood['mood_label'] ?? '').toString());
    }
    return _scoreFromCode(code).toDouble();
  }

  String _categoryFromScore(double score) {
    if (score >= 6.5) return 'Sangat Baik';
    if (score >= 5) return 'Stabil';
    if (score >= 3.5) return 'Waspada';
    return 'Bahaya';
  }

  String _selectQuote(String mood, double? score) {
    if (score != null) {
      if (score >= 6.5) {
        return 'Kamu sedang berada di kondisi yang baik, lanjutkan kebiasaan positif ini.';
      }
      if (score >= 5) {
        return 'Kamu stabil hari ini, menjaga ritme kecil akan membantu mood tetap seimbang.';
      }
      if (score >= 3.5) {
        return 'Bagus kamu sudah mencatat perasaanmu. Fokus pada hal kecil yang membuatmu nyaman.';
      }
      return 'Ini waktu yang baik untuk memberi perhatian lebih pada dirimu dan bertindak dengan lembut.';
    }

    switch (mood) {
      case 'senang':
        return 'Nikmati setiap momen yang membuat senyumanmu bertambah.';
      case 'marah':
        return 'Tarik napas panjang, lalu biarkan emosi itu menjadi tenaga yang lebih baik.';
      case 'sedih':
        return 'Ada kekuatan dalam memberi dirimu waktu untuk merasakan dan sembuh.';
      case 'takut':
        return 'Ketakutan hanyalah pintu menuju keberanian yang belum kamu temui.';
      case 'biasa':
        return 'Hari-hari tenang adalah fondasi yang kuat untuk emosi positif berikutnya.';
      case 'terkejut':
        return 'Biarkan kejutan itu mengajarkanmu bahwa hidup tetap penuh warna.';
      case 'jijik':
        return 'Emosi ini memberi tahu bahwa kamu peduli pada kesejahteraanmu, hargai itu.';
      default:
        return 'Buka hati dan pikiranmu; kata-kata baik dapat memberi ruang untuk kelegaan.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final latestMood = _latestMoodEntry();
    final moodLabel = latestMood != null
        ? (latestMood['mood_label'] ?? '').toString().toLowerCase()
        : '';
    final score = latestMood != null ? _calculateScore(latestMood) : null;
    final category = score != null ? _categoryFromScore(score) : null;
    final quote = _selectQuote(moodLabel, score);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quotes'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kondisi mood: ${moodLabel.isNotEmpty ? moodLabel.capitalize() : 'Belum ada data'}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (score != null) ...[
                Text(
                  'Skor mood: ${score.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kategori: $category',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ] else ...[
                const Text(
                  'Belum ada data riwayat mood untuk menampilkan skor',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  quote,
                  style: const TextStyle(fontSize: 17, height: 1.6),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Quotes lain untukmu',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView(
                  children: const [
                    QuoteCard(text: 'Kamu tidak harus selalu kuat. Merasa lelah adalah manusiawi.'),
                    QuoteCard(text: 'Setiap hari adalah kesempatan baru untuk memulai lagi.'),
                    QuoteCard(text: 'Perhatikan hal kecil yang membuatmu merasa lebih baik.'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringCapitalization on String {
  String capitalize() {
    if (isEmpty) return this;
    return substring(0, 1).toUpperCase() + substring(1);
  }
}

class QuoteCard extends StatelessWidget {
  final String text;

  const QuoteCard({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, height: 1.6),
      ),
    );
  }
}
