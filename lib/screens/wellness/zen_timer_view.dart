import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ZenTimerView extends StatefulWidget {
  const ZenTimerView({super.key});

  @override
  State<ZenTimerView> createState() => _ZenTimerViewState();
}

class _ZenTimerViewState extends State<ZenTimerView> with TickerProviderStateMixin {
  int _seconds = 300; 
  int _initialSeconds = 300;
  Timer? _timer;
  bool _isRunning = false;

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_seconds > 0) {
          setState(() => _seconds--);
        } else {
          timer.cancel();
          setState(() => _isRunning = false);
          _showCompletion();
        }
      });
    }
    setState(() => _isRunning = !_isRunning);
  }

  void _showCompletion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text('ZEN ACHIEVED', style: GoogleFonts.orbitron(color: Colors.cyanAccent)),
        content: Text('Keheningan telah selesai. Pikiranmu kini lebih jernih.', style: const TextStyle(color: Colors.white70)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK', style: TextStyle(color: Colors.cyanAccent)))],
      ),
    );
  }

  String _formatTime(int s) {
    int m = s ~/ 60;
    int ss = s % 60;
    return '${m.toString().padLeft(2, '0')}:${ss.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = _seconds / _initialSeconds;
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text('HENING SEJENAK', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 16)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Tinggalkan kebisingan dunia.', style: GoogleFonts.poppins(color: Colors.white60)),
            const SizedBox(height: 60),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 280, height: 280,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
                  ),
                ),
                Text(_formatTime(_seconds), style: GoogleFonts.orbitron(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _timeButton(1, '1M'),
                const SizedBox(width: 12),
                _timeButton(5, '5M'),
                const SizedBox(width: 12),
                _timeButton(10, '10M'),
              ],
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: _toggleTimer,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRunning ? Colors.white10 : Colors.cyanAccent,
                foregroundColor: _isRunning ? Colors.white : Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
              ),
              child: Text(_isRunning ? 'JEDA' : 'MULAI KEHENINGAN', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeButton(int m, String label) {
    bool isSelected = _initialSeconds == m * 60;
    return ActionChip(
      label: Text(label, style: TextStyle(color: isSelected ? Colors.black : Colors.white)),
      onPressed: _isRunning ? null : () => setState(() { _seconds = m * 60; _initialSeconds = m * 60; }),
      backgroundColor: isSelected ? Colors.cyanAccent : Colors.white10,
      side: BorderSide.none,
    );
  }
}
