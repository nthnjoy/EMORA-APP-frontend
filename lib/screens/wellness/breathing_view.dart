import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum BreathingPattern { box, relax478 }

class BreathingView extends StatefulWidget {
  final BreathingPattern pattern;
  const BreathingView({super.key, this.pattern = BreathingPattern.box});

  @override
  State<BreathingView> createState() => _BreathingViewState();
}

class _BreathingViewState extends State<BreathingView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  
  String _currentStep = 'Siap?';
  String _subText = 'Tarik napas untuk memulai';
  bool _isActive = false;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.6).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void _startBreathing() {
    setState(() {
      _isActive = true;
      _runCycle();
    });
  }

  void _runCycle() async {
    if (!mounted || !_isActive) return;

    // 1. INHALE (Always 4s)
    _controller.duration = const Duration(seconds: 4);
    setState(() { _currentStep = 'Tarik Napas'; _subText = 'Hirup udara lewat hidung'; _secondsRemaining = 4; });
    _controller.forward();
    await _countdown(4);

    if (!mounted || !_isActive) return;
    // 2. HOLD (4s for box, 7s for relax)
    int hold1 = widget.pattern == BreathingPattern.box ? 4 : 7;
    setState(() { _currentStep = 'Tahan'; _subText = 'Tahan napasmu'; _secondsRemaining = hold1; });
    await _countdown(hold1);

    if (!mounted || !_isActive) return;
    // 3. EXHALE (4s for box, 8s for relax)
    int exhale = widget.pattern == BreathingPattern.box ? 4 : 8;
    _controller.duration = Duration(seconds: exhale);
    setState(() { _currentStep = 'Hembuskan'; _subText = 'Keluarkan lewat mulut (seperti meniup)'; _secondsRemaining = exhale; });
    _controller.reverse();
    await _countdown(exhale);

    if (!mounted || !_isActive) return;
    // 4. HOLD (4s only for box)
    if (widget.pattern == BreathingPattern.box) {
      setState(() { _currentStep = 'Tahan'; _subText = 'Rileks sejenak'; _secondsRemaining = 4; });
      await _countdown(4);
    }

    if (_isActive) _runCycle();
  }

  Future<void> _countdown(int seconds) async {
    for (int i = seconds; i > 0; i--) {
      if (!mounted || !_isActive) return;
      setState(() => _secondsRemaining = i);
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  void _stopBreathing() {
    setState(() {
      _isActive = false;
      _currentStep = 'Selesai';
      _subText = 'Bagaimana perasaanmu?';
      _controller.stop();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text(widget.pattern == BreathingPattern.box ? 'BOX BREATHING' : '4-7-8 RELAX', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 16)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(animation: _pulseAnimation, builder: (c, _) => Container(width: 180 * _pulseAnimation.value, height: 180 * _pulseAnimation.value, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.cyanAccent.withOpacity(0.1)))),
                Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.cyanAccent, boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.5), blurRadius: 20)]),
                  child: Center(child: Text('$_secondsRemaining', style: GoogleFonts.orbitron(color: const Color(0xFF0F172A), fontSize: 40, fontWeight: FontWeight.bold))),
                ),
              ],
            ),
            const SizedBox(height: 80),
            Text(_currentStep, style: GoogleFonts.orbitron(fontSize: 32, color: Colors.white)),
            const SizedBox(height: 16),
            Text(_subText, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 80),
            ElevatedButton(
              onPressed: _isActive ? _stopBreathing : _startBreathing,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20)),
              child: Text(_isActive ? 'STOP' : 'START', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
