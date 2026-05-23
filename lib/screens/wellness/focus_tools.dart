import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CatchStarsView extends StatefulWidget {
  const CatchStarsView({super.key});
  @override State<CatchStarsView> createState() => _CatchStarsViewState();
}
class _CatchStarsViewState extends State<CatchStarsView> {
  int collected = 0;
  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade900,
      appBar: AppBar(title: const Text('Tangkap Bintang')),
      body: Stack(children: List.generate(5, (i) => Positioned(
        top: 100.0 * i, left: 50.0 * i, 
        child: IconButton(icon: const Icon(Icons.star, color: Colors.yellow), onPressed: () => setState(() => collected++))
      ))),
    );
  }
}

class PopcornView extends StatefulWidget {
  const PopcornView({super.key});
  @override State<PopcornView> createState() => _PopcornViewState();
}
class _PopcornViewState extends State<PopcornView> {
  final List<_PopKernel> _kernels = List.generate(15, (_) => _PopKernel());
  int _score = 0;

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context))),
      body: Stack(children: [
        ..._kernels.map((k) => AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          left: k.x, top: k.y,
          child: GestureDetector(
            onTap: () => setState(() { k.pop(); _score++; }),
            child: AnimatedScale(
              scale: k.popped ? 1.5 : 1.0, duration: const Duration(milliseconds: 200),
              child: Icon(k.popped ? Icons.cloud_outlined : Icons.circle, color: k.popped ? Colors.white : Colors.amber, size: 40),
            ),
          ),
        )),
        SafeArea(child: Center(child: Column(children: [
          const SizedBox(height: 20),
          Text('POP THE STRESS', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 14)),
          Text('$_score', style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontSize: 40, fontWeight: FontWeight.bold)),
        ]))),
      ]),
    );
  }
}

class _PopKernel {
  double x = Random().nextDouble() * 300;
  double y = Random().nextDouble() * 600 + 100;
  bool popped = false;
  void pop() { popped = true; x += (Random().nextDouble() - 0.5) * 50; y -= 50; }
}

class SlicerStressView extends StatefulWidget {
  const SlicerStressView({super.key});
  @override State<SlicerStressView> createState() => _SlicerStressViewState();
}
class _SlicerStressViewState extends State<SlicerStressView> {
  List<Offset> _trail = [];
  int _slices = 0;

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context))),
      body: GestureDetector(
        onPanUpdate: (d) => setState(() { _trail.add(d.localPosition); if(_trail.length > 10) _trail.removeAt(0); }),
        onPanEnd: (_) => setState(() { _trail.clear(); _slices++; }),
        child: Stack(children: [
          Center(child: Icon(Icons.block, size: 200 - (_slices * 5).clamp(0, 150).toDouble(), color: Colors.redAccent.withOpacity(0.8))),
          CustomPaint(painter: _SlicerPainter(_trail), size: Size.infinite),
          Positioned(top: 20, left: 0, right: 0, child: Center(child: Text('SLICE TO DELETE STRESS: $_slices', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 12)))),
        ]),
      ),
    );
  }
}
class _SlicerPainter extends CustomPainter {
  final List<Offset> trail;
  _SlicerPainter(this.trail);
  @override void paint(Canvas canvas, Size size) {
    if (trail.length < 2) return;
    Paint p = Paint()..color = Colors.cyanAccent..strokeWidth = 5..strokeCap = StrokeCap.round..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    for (int i = 0; i < trail.length - 1; i++) canvas.drawLine(trail[i], trail[i+1], p);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class TreeGrowView extends StatefulWidget {
  const TreeGrowView({super.key});
  @override State<TreeGrowView> createState() => _TreeGrowViewState();
}
class _TreeGrowViewState extends State<TreeGrowView> {
  int leaves = 0;
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tanam Harapan')),
      body: GestureDetector(onTap: () => setState(() => leaves++), child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.park, size: 100 + (leaves.toDouble() * 2), color: Colors.green),
        Text('Ketuk untuk menumbuhkan daun: $leaves')
      ]))),
    );
  }
}
