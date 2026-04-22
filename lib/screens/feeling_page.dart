import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class FeelingPage extends StatefulWidget {
  final String selectedMood;

  const FeelingPage({
    super.key,
    required this.selectedMood,
  });

  @override
  State<FeelingPage> createState() => _FeelingPageState();
}

class _FeelingPageState extends State<FeelingPage> {
  String? selectedFeeling;

  final Map<String, List<String>> feelingMap = {
    'Senang': [
      'Aktif',
      'Antusias',
      'Bosan',
      'Jemu',
      'Bersemangat',
      'Malas',
      'Takut',
      'Marah',
      'Cemas',
      'Gugup',
      'Letih',
      'Santai',
      'Kalem',
      'Damai',
      'Gugup',
      'Enerjik',
      'Tenang',
    ],
    'Marah': [
      'Kesal',
      'Tersinggung',
      'Jengkel',
      'Emosi',
      'Geram',
      'Frustrasi',
      'Kecewa',
      'Tegang',
    ],
    'Sedih': [
      'Kecewa',
      'Murung',
      'Kesepian',
      'Hampa',
      'Menyesal',
      'Lelah',
      'Terpuruk',
      'Putus Asa',
    ],
    'Takut': [
      'Khawatir',
      'Panik',
      'Tidak Aman',
      'Tegang',
      'Curiga',
      'Gelisah',
      'Cemas',
      'Gugup',
    ],
    'Biasa': [
      'Netral',
      'Tenang',
      'Stabil',
      'Santai',
      'Kalem',
      'Fokus',
    ],
    'Terkejut': [
      'Kaget',
      'Bingung',
      'Takjub',
      'Heran',
      'Terpana',
      'Tercengang',
    ],
    'Jijik': [
      'Muak',
      'Tidak Suka',
      'Mual',
      'Terganggu',
      'Risih',
      'Enggan',
    ],
  };

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

    final List<String> feelings =
        feelingMap[widget.selectedMood] ?? ['Tenang', 'Cemas', 'Fokus'];

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
                          const TextSpan(text: 'Bagaimana\nperasaanmu, '),
                          TextSpan(
                            text: '$userName?',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Expanded(
                      child: GridView.builder(
                        itemCount: feelings.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 18,
                          crossAxisSpacing: 18,
                          childAspectRatio: 0.82,
                        ),
                        itemBuilder: (context, index) {
                          final feeling = feelings[index];
                          final bool isSelected = selectedFeeling == feeling;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedFeeling = feeling;
                              });
                            },
                            child: Column(
                              children: [
                                Container(
                                  width: 54,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.shade300,
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF1E88E5)
                                          : Colors.black45,
                                      width: isSelected ? 2.4 : 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  feeling,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: selectedFeeling == null
                            ? null
                            : () {
                                Navigator.pop(context, selectedFeeling);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E88E5),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          selectedFeeling == null
                              ? 'Pilih Perasaan'
                              : 'Lanjut: $selectedFeeling',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
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