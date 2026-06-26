import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RubStressView extends StatefulWidget {
  const RubStressView({super.key});
  @override State<RubStressView> createState() => _RubStressViewState();
}

class _RubStressViewState extends State<RubStressView> {
  double _opacity = 1.0;
  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Bersihkan Pikiran'), elevation: 0),
      body: GestureDetector(
        onPanUpdate: (d) => setState(() => _opacity = (_opacity - 0.01).clamp(0.0, 1.0)),
        child: Center(
          child: Opacity(
            opacity: _opacity,
            child: Container(width: double.infinity, height: double.infinity, color: Colors.grey.shade800, 
              child: const Center(child: Text('Gosok layar untuk menjernihkan...', style: TextStyle(color: Colors.white, fontSize: 18)))),
          ),
        ),
      ),
    );
  }
}

class ElasticBandView extends StatefulWidget {
  const ElasticBandView({super.key});
  @override State<ElasticBandView> createState() => _ElasticBandViewState();
}
class _ElasticBandViewState extends State<ElasticBandView> {
  double _stretch = 0.0;
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Karet Elastis')),
      body: GestureDetector(
        onPanUpdate: (d) => setState(() => _stretch = (d.localPosition.dy - 300).abs() / 200),
        onPanEnd: (d) => setState(() => _stretch = 0.0),
        child: Center(
          child: Container(height: 20 + (100 * _stretch), width: 200, decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(10))),
        ),
      ),
    );
  }
}

class FidgetSpinnerView extends StatefulWidget {
  const FidgetSpinnerView({super.key});
  @override State<FidgetSpinnerView> createState() => _FidgetSpinnerViewState();
}
class _FidgetSpinnerViewState extends State<FidgetSpinnerView> with TickerProviderStateMixin {
  double _angle = 0.0;
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Putar Ketenangan')),
      body: GestureDetector(
        onPanUpdate: (d) => setState(() => _angle += d.delta.dx / 100),
        child: Center(
          child: Transform.rotate(angle: _angle, child: const Icon(Icons.incomplete_circle_rounded, size: 200, color: Colors.indigo)),
        ),
      ),
    );
  }
}

class WindChimesView extends StatelessWidget {
  const WindChimesView({super.key});
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Genta Angin')),
      body: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(5, (i) => 
        GestureDetector(onTap: () {}, child: Container(width: 20, height: (200 + (30 * i)).toDouble(), color: Colors.grey.shade400))
      )),
    );
  }
}

class BallBalanceView extends StatefulWidget {
  const BallBalanceView({super.key});
  @override State<BallBalanceView> createState() => _BallBalanceViewState();
}
class _BallBalanceViewState extends State<BallBalanceView> {
  Offset _pos = Offset.zero;
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keseimbangan')),
      body: GestureDetector(
        onPanUpdate: (d) => setState(() => _pos += d.delta),
        child: Center(child: Transform.translate(offset: _pos, child: const CircleAvatar(radius: 30, backgroundColor: Colors.red))),
      ),
    );
  }
}
