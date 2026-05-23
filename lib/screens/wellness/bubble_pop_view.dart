import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BubblePopView extends StatefulWidget {
  const BubblePopView({super.key});

  @override
  State<BubblePopView> createState() => _BubblePopViewState();
}

class _BubblePopViewState extends State<BubblePopView> {
  List<Bubble> bubbles = [];
  int score = 0;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _generateBubbles();
  }

  void _generateBubbles() {
    for (int i = 0; i < 15; i++) {
      bubbles.add(Bubble(
        id: i,
        x: random.nextDouble() * 300,
        y: random.nextDouble() * 500,
        size: 40 + random.nextDouble() * 40,
        color: Colors.blue.withOpacity(0.3),
      ));
    }
  }

  void _pop(int index) {
    setState(() {
      bubbles.removeAt(index);
      score++;
      // Add a replacement bubble after a delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            bubbles.add(Bubble(
              id: DateTime.now().millisecondsSinceEpoch,
              x: random.nextDouble() * 300,
              y: random.nextDouble() * 500,
              size: 40 + random.nextDouble() * 40,
              color: Colors.blue.withOpacity(0.3),
            ));
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          ...bubbles.asMap().entries.map((e) => Positioned(
                left: e.value.x,
                top: e.value.y,
                child: GestureDetector(
                  onTap: () => _pop(e.key),
                  child: Container(
                    width: e.value.size,
                    height: e.value.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [e.value.color.withOpacity(0.5), e.value.color],
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: e.value.color.withOpacity(0.4),
                            blurRadius: 10)
                      ],
                    ),
                  ),
                ),
              )).toList(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.white)),
                      Column(
                        children: [
                          Text('STRESS SMASHED',
                              style: GoogleFonts.orbitron(
                                  fontSize: 10, color: Colors.cyanAccent)),
                          Text('$score',
                              style: GoogleFonts.orbitron(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ],
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Bubble {
  final int id;
  final double x;
  final double y;
  final double size;
  final Color color;

  Bubble({required this.id, required this.x, required this.y, required this.size, required this.color});
}
