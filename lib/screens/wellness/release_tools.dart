import 'dart:math';
import 'package:flutter/material.dart';

class ElasticStringsView extends StatelessWidget {
  const ElasticStringsView({super.key});
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tali Elastis')),
      body: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(4, (i) => 
        const VerticalDivider(thickness: 5, color: Colors.blue)
      )),
    );
  }
}

class ColorSorterView extends StatefulWidget {
  const ColorSorterView({super.key});
  @override State<ColorSorterView> createState() => _ColorSorterViewState();
}
class _ColorSorterViewState extends State<ColorSorterView> {
  Offset pos = const Offset(100, 100);
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Penyortir Warna')),
      body: Stack(children: [
        Positioned(left: 0, child: Container(width: 100, height: 1000, color: Colors.red.withOpacity(0.1))),
        Positioned(right: 0, child: Container(width: 100, height: 1000, color: Colors.blue.withOpacity(0.1))),
        Positioned(
          left: pos.dx, top: pos.dy,
          child: Draggable(
            feedback: const Icon(Icons.circle, color: Colors.blue, size: 50),
            child: const Icon(Icons.circle, color: Colors.blue, size: 50),
            onDragUpdate: (d) => setState(() => pos = d.localPosition),
          ),
        ),
      ]),
    );
  }
}

class MusicTilesView extends StatefulWidget {
  const MusicTilesView({super.key});
  @override State<MusicTilesView> createState() => _MusicTilesViewState();
}
class _MusicTilesViewState extends State<MusicTilesView> {
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Harmoni Ketukan')),
      body: GridView.count(crossAxisCount: 2, children: List.generate(4, (i) => 
        InkWell(
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ting!'), duration: Duration(milliseconds: 200))),
          child: Container(margin: const EdgeInsets.all(10), color: Colors.purple.shade100, child: const Center(child: Icon(Icons.music_note))),
        )
      )),
    );
  }
}

class FocusCircleView extends StatefulWidget {
  const FocusCircleView({super.key});
  @override State<FocusCircleView> createState() => _FocusCircleViewState();
}
class _FocusCircleViewState extends State<FocusCircleView> {
  bool focusing = false;
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pusat Fokus')),
      body: Center(
        child: GestureDetector(
          onLongPressStart: (d) => setState(() => focusing = true),
          onLongPressEnd: (d) => setState(() => focusing = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.all(focusing ? 40 : 20),
            decoration: BoxDecoration(color: focusing ? Colors.blue : Colors.blue.shade100, shape: BoxShape.circle),
            child: const Text('Tahan'),
          ),
        ),
      ),
    );
  }
}

class PuzzleMiniView extends StatelessWidget {
  const PuzzleMiniView({super.key});
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Puzzle Santai')),
      body: GridView.count(crossAxisCount: 2, children: List.generate(4, (i) => 
        Container(margin: const EdgeInsets.all(5), color: Colors.grey.shade300, child: Center(child: Text('${i+1}')))
      )),
    );
  }
}
