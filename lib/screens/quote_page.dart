import 'package:flutter/material.dart';
import '../utils/quote_data.dart';
import '../services/ai_service.dart';

class QuotesPage extends StatefulWidget {
  final List<Map<String, dynamic>> moods;
  final List<Map<String, dynamic>> stories;

  const QuotesPage({super.key, required this.moods, required this.stories});

  @override
  State<QuotesPage> createState() => _QuotesPageState();
}

class _QuotesPageState extends State<QuotesPage> {
  String? _aiQuote;
  bool _isLoadingAi = true;

  @override
  void initState() {
    super.initState();
    _fetchAiQuote();
  }

  Future<void> _fetchAiQuote() async {
    final latestMood = _latestMoodEntry();
    final mood = latestMood != null ? (latestMood['mood_label'] ?? '').toString() : null;
    final feeling = latestMood != null ? (latestMood['perasaan'] ?? '').toString() : null;

    final result = await AiService.getRecommendation(mood: mood, feeling: feeling);
    
    if (mounted) {
      setState(() {
        if (result['status'] == 'success') {
          _aiQuote = result['quote'];
        }
        _isLoadingAi = false;
      });
    }
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty) return null;
    return DateTime.tryParse(text)?.toLocal();
  }

  Map<String, dynamic>? _latestMoodEntry() {
    final sorted = widget.moods.where((item) {
      return (item['recorded_at'] ?? item['created_at']) != null;
    }).toList();

    sorted.sort((a, b) {
      final da = _parseDate(a['recorded_at'] ?? a['created_at']);
      final db = _parseDate(b['recorded_at'] ?? b['created_at']);
      if (da == null || db == null) return 0;
      return db.compareTo(da);
    });

    if (sorted.isEmpty) return null;
    return Map<String, dynamic>.from(sorted.first);
  }

  int _scoreFromCode(int code) {
    switch (code) {
      case 1: return 7;
      case 2: return 2;
      case 3: return 5;
      case 4: return 4;
      case 5: return 6;
      case 6: return 3;
      case 7: return 1;
      default: return 5;
    }
  }

  int _codeFromLabel(String moodLabel) {
    switch (moodLabel.toLowerCase()) {
      case 'senang': return 1;
      case 'marah': return 2;
      case 'sedih': return 3;
      case 'takut': return 4;
      case 'biasa': return 5;
      case 'terkejut': return 6;
      case 'jijik': return 7;
      default: return 5;
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

  @override
  Widget build(BuildContext context) {
    final latestMood = _latestMoodEntry();
    final moodLabel = latestMood != null
        ? (latestMood['mood_label'] ?? '').toString().toLowerCase()
        : '';
    final feeling = latestMood != null
        ? (latestMood['perasaan'] ?? '').toString()
        : '';
    final score = latestMood != null ? _calculateScore(latestMood) : null;
    final category = score != null ? _categoryFromScore(score) : null;
    final primaryColor = Theme.of(context).primaryColor;

    final inspirations = QuoteData.getRandomInspirations(category ?? 'Stabil', 3);
    final fallbackQuote = QuoteData.getRandomQuote(moodLabel);
    final displayedQuote = _aiQuote ?? fallbackQuote;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        title: const Text(
          'Quotes Untukmu',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(_isLoadingAi ? Icons.sync : Icons.auto_awesome, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _isLoadingAi ? 'Quotes yang cocok untuk kondisi kamu saat ini' : 'Quotes untukmu',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _isLoadingAi 
                      ? const SizedBox(
                          height: 60,
                          child: Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                        )
                      : Text(
                          displayedQuote,
                          style: const TextStyle(
                            fontSize: 20,
                            height: 1.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    const SizedBox(height: 12),
                    if (moodLabel.isNotEmpty || feeling.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Mood: $moodLabel, Feeling: $feeling',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              const Text(
                'Inspirasi Harian',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Temukan kata-kata bijak untuk harimu',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              
              ...inspirations.map((ins) => QuoteCard(
                text: ins['text'],
                icon: _iconFromEmoji(ins['icon']),
                accentColor: primaryColor,
              )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFromEmoji(String emoji) {
    switch (emoji) {
      case '🌟': return Icons.star;
      case '❤️': return Icons.favorite;
      case '🚀': return Icons.rocket_launch;
      case '🏆': return Icons.emoji_events;
      case '💡': return Icons.lightbulb;
      case '🛡️': return Icons.shield;
      case '🎯': return Icons.track_changes;
      case '✨': return Icons.auto_awesome;
      case '🎊': return Icons.celebration;
      case '🌍': return Icons.public;
      case '⚖️': return Icons.balance;
      case '📚': return Icons.book;
      case '🐢': return Icons.slow_motion_video;
      case '🧘': return Icons.self_improvement;
      case '⚓': return Icons.anchor;
      case '🚶': return Icons.directions_walk;
      case '🛠️': return Icons.build;
      case '📝': return Icons.note_alt;
      case '🛤️': return Icons.alt_route;
      case '🏡': return Icons.home;
      case '⚠️': return Icons.warning;
      case '🔍': return Icons.search;
      case '🗣️': return Icons.chat;
      case '🛑': return Icons.stop;
      case '🌬️': return Icons.air;
      case '📵': return Icons.phonelink_erase;
      case '☁️': return Icons.cloud;
      case '🍏': return Icons.apple;
      case '🎵': return Icons.music_note;
      case '🆘': return Icons.help_center;
      case '🤝': return Icons.handshake;
      case '🚪': return Icons.door_front_door;
      case '⛈️': return Icons.thunderstorm;
      case '🩹': return Icons.healing;
      case '📢': return Icons.campaign;
      case '⏳': return Icons.timer;
      case '🛌': return Icons.bed;
      case '💎': return Icons.diamond;
      case '🌈': return Icons.looks;
      default: return Icons.wb_sunny;
    }
  }
}

class QuoteCard extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color accentColor;

  const QuoteCard({
    super.key,
    required this.text,
    this.icon,
    this.accentColor = const Color(0xFFC0CFB2),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFC0CFB2).withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: 20),
            ),
          if (icon != null) const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.black.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
