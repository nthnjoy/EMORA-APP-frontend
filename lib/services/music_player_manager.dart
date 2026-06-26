import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../screens/music_page.dart';

class MusicPlayerManager extends ChangeNotifier {
  static final MusicPlayerManager _instance = MusicPlayerManager._internal();
  factory MusicPlayerManager() => _instance;

  MusicPlayerManager._internal() {
    _initializeAudioPlayer();
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  MusicTrack? _currentTrack;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  AudioPlayer get audioPlayer => _audioPlayer;
  MusicTrack? get currentTrack => _currentTrack;
  bool get isPlaying => _isPlaying;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;

  void _initializeAudioPlayer() {
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
    _audioPlayer.setVolume(1.0);

    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      _totalDuration = duration;
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((position) {
      _currentPosition = position;
      notifyListeners();
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      _isPlaying = false;
      _currentPosition = _totalDuration;
      notifyListeners();
    });
  }

  Future<void> playTrack(MusicTrack track) async {
    if (_currentTrack?.audioUrl == track.audioUrl) {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.resume();
      }
      return;
    }

    await _audioPlayer.stop();
    _currentTrack = track;
    _isPlaying = true;
    _currentPosition = Duration.zero;
    _totalDuration = Duration.zero;
    notifyListeners();

    try {
      await _audioPlayer.play(UrlSource(track.audioUrl), volume: 1.0);
    } catch (e) {
      debugPrint('Audio playback error: $e');
      _isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> togglePlayPause() async {
    if (_currentTrack == null) return;
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  Future<void> pauseTrack() async {
    await _audioPlayer.pause();
  }

  Future<void> resumeTrack() async {
    await _audioPlayer.resume();
  }

  Future<void> stopTrack() async {
    await _audioPlayer.stop();
    _currentTrack = null;
    _isPlaying = false;
    _currentPosition = Duration.zero;
    _totalDuration = Duration.zero;
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }
}
