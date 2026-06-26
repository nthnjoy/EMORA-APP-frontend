import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FlowerBloomView extends StatefulWidget {
  const FlowerBloomView({super.key});
  @override State<FlowerBloomView> createState() => _FlowerBloomViewState();
}
class _FlowerBloomViewState extends State<FlowerBloomView> {
  double _size = 50.0;
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mekarkan Bunga')),
      body: GestureDetector(
        onLongPressStart: (d) => Timer.periodic(const Duration(milliseconds: 50), (t) => setState(() => _size += 2)),
        onLongPressEnd: (d) {},
        child: Center(child: Icon(Icons.local_florist, size: _size, color: Colors.pink)),
      ),
    );
  }
}

class ColoringView extends StatefulWidget {
  const ColoringView({super.key});
  @override State<ColoringView> createState() => _ColoringViewState();
}
class _ColoringViewState extends State<ColoringView> {
  Color _c = Colors.white;
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Warna Ketenangan')),
      body: Column(children: [
        Expanded(child: Container(color: _c, child: const Center(child: Icon(Icons.star, size: 200)))),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [Colors.red, Colors.blue, Colors.green].map((c) => IconButton(icon: Icon(Icons.circle, color: c), onPressed: () => setState(() => _c = c))).toList())
      ]),
    );
  }
}

class RainyWindowView extends StatefulWidget {
  const RainyWindowView({super.key});
  @override State<RainyWindowView> createState() => _RainyWindowViewState();
}
class _RainyWindowViewState extends State<RainyWindowView> {
  List<Offset> points = [];
  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(title: const Text('Jendela Hujan')),
      body: GestureDetector(
        onPanUpdate: (d) => setState(() => points.add(d.localPosition)),
        child: CustomPaint(painter: FogPainter(points: points), size: Size.infinite),
      ),
    );
  }
}
class FogPainter extends CustomPainter {
  final List<Offset> points;
  FogPainter({required this.points});
  @override void paint(Canvas canvas, Size size) {
    Paint p = Paint()..color = Colors.white.withOpacity(0.3)..strokeWidth = 20..strokeCap = StrokeCap.round;
    for (var pt in points) canvas.drawCircle(pt, 10, p);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ConnectDotsView extends StatefulWidget {
  const ConnectDotsView({super.key});
  @override State<ConnectDotsView> createState() => _ConnectDotsViewState();
}
class _ConnectDotsViewState extends State<ConnectDotsView> {
  List<Offset> points = [];
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hubungkan Titik')),
      body: GestureDetector(
        onPanUpdate: (d) => setState(() => points.add(d.localPosition)),
        onPanEnd: (d) => setState(() => points = []),
        child: CustomPaint(
          painter: LinePainter(points: points),
          size: Size.infinite,
          child: Stack(children: [
            const Positioned(top: 100, left: 100, child: CircleAvatar(radius: 10, child: Text('1'))),
            const Positioned(top: 300, left: 200, child: CircleAvatar(radius: 10, child: Text('2'))),
            const Positioned(top: 500, left: 100, child: CircleAvatar(radius: 10, child: Text('3'))),
          ]),
        ),
      ),
    );
  }
}
class LinePainter extends CustomPainter {
  final List<Offset> points;
  LinePainter({required this.points});
  @override void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    Paint p = Paint()..color = Colors.blue..strokeWidth = 4..strokeCap = StrokeCap.round;
    for (var i = 0; i < points.length - 1; i++) canvas.drawLine(points[i], points[i+1], p);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class MagicSandView extends StatefulWidget {
  const MagicSandView({super.key});
  @override State<MagicSandView> createState() => _MagicSandViewState();
}
class _MagicSandViewState extends State<MagicSandView> with SingleTickerProviderStateMixin {
  final List<_Sand> _sand = [];
  late AnimationController _c;

  @override void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 16))..addListener(() {
      setState(() {
        for (var s in _sand) { s.y += 2; if(s.y > 800) s.y = 800; }
      });
    })..repeat();
  }
  @override void dispose() { _c.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text('MAGIC SAND', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 16)),
        actions: [IconButton(icon: const Icon(Icons.refresh, color: Colors.cyanAccent), onPressed: () => setState(() => _sand.clear()))],
      ),
      body: GestureDetector(
        onPanUpdate: (d) => setState(() {
          for(int i=0; i<5; i++) _sand.add(_Sand(d.localPosition.dx + Random().nextDouble()*20-10, d.localPosition.dy + Random().nextDouble()*20-10));
        }),
        child: CustomPaint(painter: _SandPainter(_sand), size: Size.infinite),
      ),
    );
  }
}
class _Sand { double x, y; _Sand(this.x, this.y); }
class _SandPainter extends CustomPainter {
  final List<_Sand> sand;
  _SandPainter(this.sand);
  @override void paint(Canvas canvas, Size size) {
    Paint p = Paint()..color = Colors.amberAccent.withOpacity(0.6)..strokeWidth = 2;
    for (var s in sand) canvas.drawCircle(Offset(s.x, s.y), 1.5, p);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
