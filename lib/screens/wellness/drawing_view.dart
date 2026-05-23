import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DrawingView extends StatefulWidget {
  const DrawingView({super.key});

  @override
  State<DrawingView> createState() => _DrawingViewState();
}

class _DrawingViewState extends State<DrawingView> {
  List<DrawPoint?> points = [];
  Color selectedColor = Colors.cyanAccent;
  double strokeWidth = 5.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text('ZEN ART', style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 2)),
        actions: [
          IconButton(icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent), onPressed: () => setState(() => points.clear())),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('DONE', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold))),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      RenderBox renderBox = context.findRenderObject() as RenderBox;
                      points.add(DrawPoint(
                        offset: renderBox.globalToLocal(details.globalPosition).translate(0, -70),
                        paint: Paint()
                          ..color = selectedColor
                          ..strokeCap = StrokeCap.round
                          ..strokeWidth = strokeWidth,
                      ));
                    });
                  },
                  onPanEnd: (details) => setState(() => points.add(null)),
                  child: CustomPaint(painter: DrawingPainter(points: points), size: Size.infinite),
                ),
              ),
            ),
          ),
          _buildToolbar(),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    final colors = [Colors.cyanAccent, Colors.pinkAccent, Colors.orangeAccent, Colors.greenAccent, Colors.white, Colors.purpleAccent, Colors.blueAccent];
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      color: const Color(0xFF1E293B),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: colors.map((c) => GestureDetector(
                onTap: () => setState(() => selectedColor = c),
                child: Container(
                  margin: const EdgeInsets.only(right: 15),
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: c, shape: BoxShape.circle,
                    border: Border.all(color: selectedColor == c ? Colors.white : Colors.transparent, width: 3),
                    boxShadow: [if(selectedColor == c) BoxShadow(color: c.withOpacity(0.5), blurRadius: 10)],
                  ),
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 20),
          Slider(
            value: strokeWidth, min: 2, max: 20,
            activeColor: selectedColor, inactiveColor: Colors.white10,
            onChanged: (v) => setState(() => strokeWidth = v),
          ),
        ],
      ),
    );
  }
}

class DrawPoint {
  final Offset offset;
  final Paint paint;
  DrawPoint({required this.offset, required this.paint});
}

class DrawingPainter extends CustomPainter {
  final List<DrawPoint?> points;
  DrawingPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!.offset, points[i + 1]!.offset, points[i]!.paint);
      } else if (points[i] != null && points[i + 1] == null) {
        canvas.drawCircle(points[i]!.offset, points[i]!.paint.strokeWidth / 2, points[i]!.paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) => true;
}
