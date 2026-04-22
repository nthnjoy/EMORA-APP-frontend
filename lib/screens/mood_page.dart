import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'feeling_page.dart';

class MoodPage extends StatefulWidget {
  const MoodPage({super.key});

  @override
  State<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends State<MoodPage> {
  String? selectedMood;
  String? selectedFeeling;

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
      MaterialPageRoute(
        builder: (_) => FeelingPage(selectedMood: mood),
      ),
    );

    if (result != null) {
      setState(() {
        selectedMood = mood;
        selectedFeeling = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.currentUser;

    final String userName =
        (user?.displayName != null && user!.displayName!.trim().isNotEmpty)
            ? user.displayName!.trim()
            : (user?.email != null && user!.email!.contains('@')
                ? user.email!.split('@')[0]
                : 'User');

    return Scaffold(
      backgroundColor: const Color(0xFFDCEEFF),
      body: SafeArea(
        child: Column(
          children: [
            const _TopHeader(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          height: 1.2,
                        ),
                        children: [
                          const TextSpan(text: 'Bagaimana\nsuasana hatimu, '),
                          TextSpan(
                            text: '$userName?',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Catatan harian ini membantu Anda memantau\nemosi dan kesejahteraan mental setiap hari.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 30),

                    Expanded(
                      child: Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 14,
                          runSpacing: 18,
                          children: moods.map((mood) {
                            final bool isLast = mood['label'] == 'Jijik';

                            return SizedBox(
                              width: isLast ? 100 : 72,
                              child: GestureDetector(
                                onTap: () => goToFeelingPage(mood['label']),
                                child: Container(
                                  height: 86,
                                  decoration: BoxDecoration(
                                    color: mood['bgColor'],
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: mood['borderColor'],
                                      width: 1.6,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        mood['emoji'],
                                        style: const TextStyle(fontSize: 34),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        mood['label'],
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: mood['textColor'],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    if (selectedMood != null && selectedFeeling != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Text(
                          'Mood terpilih: $selectedMood\nPerasaan terpilih: $selectedFeeling',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const _BottomNavBar(),
          ],
        ),
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  const _TopHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Color(0xFFD94CFF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'IT DEL EMOLENS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 3),
              _StreakBadge(),
            ],
          ),
          const Spacer(),
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.wb_sunny_outlined, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFD000FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        '5 Streak',
        style: TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
          Icon(Icons.home, color: Color(0xFF3F5F7A)),
          Icon(Icons.accessibility_new, color: Color(0xFF9AA7B8)),
          Icon(Icons.calendar_today, color: Color(0xFF9AA7B8)),
          Icon(Icons.person, color: Color(0xFF9AA7B8)),
        ],
      ),
    );
  }
}