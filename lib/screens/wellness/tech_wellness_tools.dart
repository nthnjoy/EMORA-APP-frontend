import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LogicKnotView extends StatefulWidget {
  const LogicKnotView({super.key});
  @override State<LogicKnotView> createState() => _LogicKnotViewState();
}
class _LogicKnotViewState extends State<LogicKnotView> {
  List<Offset> _nodes = [];
  final int _count = 6;
  int? _draggingIdx;

  @override void initState() {
    super.initState();
    for(int i=0; i<_count; i++) _nodes.add(Offset(50.0 + Random().nextDouble()*300, 100.0 + Random().nextDouble()*500));
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context))),
      body: GestureDetector(
        onPanStart: (d) {
          for(int i=0; i<_nodes.length; i++) {
            if((_nodes[i] - d.localPosition).distance < 30) { setState(() => _draggingIdx = i); break; }
          }
        },
        onPanUpdate: (d) {
          if(_draggingIdx != null) setState(() => _nodes[_draggingIdx!] = d.localPosition);
        },
        onPanEnd: (_) => setState(() => _draggingIdx = null),
        child: Stack(children: [
          CustomPaint(painter: _KnotPainter(_nodes), size: Size.infinite),
          Positioned(top: 20, left: 0, right: 0, child: Center(child: Text('UNTANGLE YOUR THOUGHTS', style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontSize: 12)))),
          ..._nodes.asMap().entries.map((e) => Positioned(
            left: e.value.dx - 15, top: e.value.dy - 15,
            child: Container(width: 30, height: 30, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.5), blurRadius: 10)])),
          )),
        ]),
      ),
    );
  }
}
class _KnotPainter extends CustomPainter {
  final List<Offset> nodes;
  _KnotPainter(this.nodes);
  @override void paint(Canvas canvas, Size size) {
    Paint p = Paint()..color = Colors.cyanAccent.withOpacity(0.4)..strokeWidth = 2;
    for(int i=0; i<nodes.length; i++) {
      for(int j=i+1; j<nodes.length; j++) canvas.drawLine(nodes[i], nodes[j], p);
    }
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class BinaryRainView extends StatefulWidget {
  const BinaryRainView({super.key});
  @override State<BinaryRainView> createState() => _BinaryRainViewState();
}
class _BinaryRainViewState extends State<BinaryRainView> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  final List<_RainDrop> _drops = List.generate(20, (_) => _RainDrop());

  @override void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 2))..addListener(() {
      setState(() { for (var d in _drops) d.update(); });
    })..repeat();
  }
  @override void dispose() { _c.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        ..._drops.map((d) => Positioned(
          left: d.x, top: d.y,
          child: Column(children: d.chars.map((c) => Text(c, style: GoogleFonts.shareTechMono(color: Colors.greenAccent.withOpacity(0.8), fontSize: 16))).toList()),
        )),
        Positioned(top: 60, left: 24, child: Text('SYSTEM FOCUS: ENGAGED', style: GoogleFonts.orbitron(color: Colors.greenAccent, fontSize: 14))),
        Positioned(bottom: 40, left: 0, right: 0, child: Center(child: IconButton(icon: const Icon(Icons.close, color: Colors.white60), onPressed: () => Navigator.pop(context)))),
      ]),
    );
  }
}
class _RainDrop {
  double x = Random().nextDouble() * 400;
  double y = Random().nextDouble() * -800;
  double speed = 2 + Random().nextDouble() * 5;
  List<String> chars = List.generate(10, (_) => Random().nextInt(2).toString());
  void update() { y += speed; if(y > 900) { y = -200; x = Random().nextDouble() * 400; } if(Random().nextDouble() > 0.9) chars[Random().nextInt(10)] = Random().nextInt(2).toString(); }
}

class GalaxyArchitectView extends StatefulWidget {
  const GalaxyArchitectView({super.key});
  @override State<GalaxyArchitectView> createState() => _GalaxyArchitectViewState();
}
class _GalaxyArchitectViewState extends State<GalaxyArchitectView> with SingleTickerProviderStateMixin {
  final List<_Star> _stars = [];
  late AnimationController _c;

  @override void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 16))..addListener(() {
      setState(() { for (var s in _stars) s.update(); _stars.removeWhere((s) => s.life <= 0); });
    })..repeat();
  }
  @override void dispose() { _c.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context))),
      body: GestureDetector(
        onPanUpdate: (d) => setState(() { for(int i=0; i<3; i++) _stars.add(_Star(d.localPosition)); }),
        child: CustomPaint(painter: _GalaxyPainter(_stars), size: Size.infinite),
      ),
    );
  }
}
class _Star {
  Offset pos;
  double vx = (Random().nextDouble()-0.5)*4;
  double vy = (Random().nextDouble()-0.5)*4;
  double life = 1.0;
  Color color = [Colors.blueAccent, Colors.purpleAccent, Colors.cyanAccent, Colors.white][Random().nextInt(4)];
  _Star(this.pos);
  void update() { pos += Offset(vx, vy); life -= 0.01; }
}
class _GalaxyPainter extends CustomPainter {
  final List<_Star> stars;
  _GalaxyPainter(this.stars);
  @override void paint(Canvas canvas, Size size) {
    for (var s in stars) {
      Paint p = Paint()..color = s.color.withOpacity(s.life)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(s.pos, 2, p);
    }
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
