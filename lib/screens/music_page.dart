import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/mood_service.dart';
import '../services/laravel_session_service.dart';
import '../services/theme_manager.dart';
import 'package:google_fonts/google_fonts.dart';

class MusicMood {
  final String name;
  final String description;
  final String imagePath;
  final Color color;
  final List<MusicTrack> tracks;

  const MusicMood({
    required this.name,
    required this.description,
    required this.imagePath,
    required this.color,
    required this.tracks,
  });
}

class MusicTrack {
  final String title;
  final String artist;
  final String language;
  final String source;
  final String audioUrl;
  final String thumbnailUrl;
  final bool trending;

  const MusicTrack({
    required this.title,
    required this.artist,
    required this.language,
    required this.source,
    required this.audioUrl,
    required this.thumbnailUrl,
    this.trending = false,
  });
}

const List<String> languageTabs = ['Semua', 'Indonesia', 'English'];

final List<MusicMood> musicMoods = [
  MusicMood(
    name: 'Senang',
    description: 'Beat ceria yang cocok untuk produktivitas kampus.',
    imagePath: 'assets/image/senang.png',
    color: const Color(0xFFFFB347),
    tracks: [
      const MusicTrack(
        title: 'Pelita Malam',
        artist: 'Dunia Ceria',
        language: 'Indonesia',
        source: 'YouTube Music',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
        thumbnailUrl: 'https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?auto=format&fit=crop&w=500&q=80',
        trending: true,
      ),
      const MusicTrack(
        title: 'Semangat Kampus',
        artist: 'Nusa Beats',
        language: 'Indonesia',
        source: 'Spotify',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
        thumbnailUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Startup Groove',
        artist: 'CodeHouse',
        language: 'English',
        source: 'Apple Music',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
        thumbnailUrl: 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Focus Drive',
        artist: 'Future Labs',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
        thumbnailUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Neon Pulse',
        artist: 'Digital Aura',
        language: 'English',
        source: 'Free Music',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
        thumbnailUrl: 'https://images.unsplash.com/photo-1488372765830-1f3fd75c52c9?auto=format&fit=crop&w=500&q=80',
      ),
    ],
  ),
  MusicMood(
    name: 'Antusias',
    description: 'Drive tinggi untuk ide-ide coding dan presentasi.',
    imagePath: 'assets/image/antusias.png',
    color: const Color(0xFFFF6B6B),
    tracks: [
      const MusicTrack(
        title: 'Aksi Pagi',
        artist: 'Nada Harian',
        language: 'Indonesia',
        source: 'Spotify',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
        thumbnailUrl: 'https://images.unsplash.com/photo-1517816743773-6e0fd518b4a6?auto=format&fit=crop&w=500&q=80',
        trending: true,
      ),
      const MusicTrack(
        title: 'Semangat Koding',
        artist: 'Polaris Studio',
        language: 'Indonesia',
        source: 'YouTube Music',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',
        thumbnailUrl: 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Hype Loop',
        artist: 'Neon Rush',
        language: 'English',
        source: 'Apple Music',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
        thumbnailUrl: 'https://images.unsplash.com/photo-1519750157634-bf64fd465a4d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Code Sprint',
        artist: 'Velocity',
        language: 'English',
        source: 'Spotify',
        audioUrl: 'https://file-examples.com/wp-content/uploads/2017/11/file_example_MP3_700KB.mp3',
        thumbnailUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Pulse Drive',
        artist: 'Layered Beats',
        language: 'English',
        source: 'Free Music',
        audioUrl: 'https://file-examples.com/wp-content/uploads/2017/11/file_example_MP3_1MG.mp3',
        thumbnailUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=500&q=80',
      ),
    ],
  ),
  MusicMood(
    name: 'Netral',
    description: 'Suasana ambient untuk review, belajar, dan coding lama.',
    imagePath: 'assets/image/biasa.png',
    color: const Color(0xFF4ECDC4),
    tracks: [
      const MusicTrack(
        title: 'Rutinitas Tenang',
        artist: 'Senja Studio',
        language: 'Indonesia',
        source: 'YouTube',
        audioUrl: 'https://file-examples.com/wp-content/uploads/2017/11/file_example_MP3_2MG.mp3',
        thumbnailUrl: 'https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Langkah Pelan',
        artist: 'Petualang',
        language: 'Indonesia',
        source: 'Apple Music',
        audioUrl: 'https://file-examples.com/wp-content/uploads/2017/11/file_example_MP3_5MG.mp3',
        thumbnailUrl: 'https://images.unsplash.com/photo-1500534623283-312aade485b7?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Study Mode',
        artist: 'Campus Beats',
        language: 'English',
        source: 'Spotify',
        audioUrl: 'https://samplelib.com/lib/preview/mp3/sample-3s.mp3',
        thumbnailUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Cloud Desk',
        artist: 'Soft Logic',
        language: 'English',
        source: 'YouTube Music',
        audioUrl: 'https://samplelib.com/lib/preview/mp3/sample-6s.mp3',
        thumbnailUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Smooth Flow',
        artist: 'Aura Lab',
        language: 'English',
        source: 'Free Music',
        audioUrl: 'https://samplelib.com/lib/preview/mp3/sample-12s.mp3',
        thumbnailUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&w=500&q=80',
      ),
    ],
  ),
  MusicMood(
    name: 'Sedih',
    description: 'Lagu ambient lembut untuk refleksi dan relaksasi.',
    imagePath: 'assets/image/sedih.png',
    color: const Color(0xFF6C5CE7),
    tracks: [
      const MusicTrack(
        title: 'Hujan Malam',
        artist: 'Senandung',
        language: 'Indonesia',
        source: 'YouTube Music',
        audioUrl: 'https://samplelib.com/lib/preview/mp3/sample-24s.mp3',
        thumbnailUrl: 'https://images.unsplash.com/photo-1522770179533-24471fcdba45?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Lagu Senja',
        artist: 'Nada Pelan',
        language: 'Indonesia',
        source: 'Spotify',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3',
        thumbnailUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Warm Echo',
        artist: 'Evening Code',
        language: 'English',
        source: 'Apple Music',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3',
        thumbnailUrl: 'https://images.unsplash.com/photo-1488372765830-1f3fd75c52c9?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Moonlight Memo',
        artist: 'Quiet Synth',
        language: 'English',
        source: 'Spotify',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-11.mp3',
        thumbnailUrl: 'https://images.unsplash.com/photo-1529070538774-1843cb3265df?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Soft Space',
        artist: 'Lunar Studio',
        language: 'English',
        source: 'Free Music',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-12.mp3',
        thumbnailUrl: 'https://images.unsplash.com/photo-1497215842964-222b430dc094?auto=format&fit=crop&w=500&q=80',
      ),
    ],
  ),
  MusicMood(
    name: 'Terkejut',
    description: 'Pilihan beat ekspresif untuk suasana terkejut dan semangat baru.',
    imagePath: 'assets/image/terkejut.png',
    color: const Color(0xFFB878EE),
    tracks: [
      const MusicTrack(
        title: 'Spark Moment',
        artist: 'Shockwave',
        language: 'English',
        source: 'YouTube Music',
        audioUrl: 'https://file-examples.com/wp-content/uploads/2017/11/file_example_MP3_1MG.mp3',
        thumbnailUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Flash Drive',
        artist: 'Neon Pulse',
        language: 'English',
        source: 'Spotify',
        audioUrl: 'https://file-examples.com/wp-content/uploads/2017/11/file_example_MP3_700KB.mp3',
        thumbnailUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Surprise Loop',
        artist: 'Quantum Beat',
        language: 'Indonesia',
        source: 'Apple Music',
        audioUrl: 'https://samplelib.com/lib/preview/mp3/sample-3s.mp3',
        thumbnailUrl: 'https://images.unsplash.com/photo-1490077471108-0cad1290d8b3?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Shockwave',
        artist: 'Impulse Lab',
        language: 'English',
        source: 'Free Music',
        audioUrl: 'https://samplelib.com/lib/preview/mp3/sample-6s.mp3',
        thumbnailUrl: 'https://images.unsplash.com/photo-1515871204537-7d92b94b8045?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Bright Alert',
        artist: 'Velocity Vibe',
        language: 'Indonesia',
        source: 'YouTube',
        audioUrl: 'https://samplelib.com/lib/preview/mp3/sample-12s.mp3',
        thumbnailUrl: 'https://images.unsplash.com/photo-1516321497487-e288fb19713f?auto=format&fit=crop&w=500&q=80',
      ),
    ],
  ),
  MusicMood(
    name: 'Takut',
    description: 'Suasana misterius dan ambient untuk mood sedang waspada.',
    imagePath: 'assets/image/takut.png',
    color: const Color(0xFF9CA6B2),
    tracks: [
      const MusicTrack(
        title: 'Night Watch',
        artist: 'Shadow Tunes',
        language: 'English',
        source: 'Spotify',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
        thumbnailUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Whisper Path',
        artist: 'Misty Code',
        language: 'Indonesia',
        source: 'YouTube Music',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
        thumbnailUrl: 'https://images.unsplash.com/photo-1522770179533-24471fcdba45?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Dreadflow',
        artist: 'Hidden Frequency',
        language: 'English',
        source: 'Apple Music',
        audioUrl: 'https://samplelib.com/lib/preview/mp3/sample-24s.mp3',
        thumbnailUrl: 'https://images.unsplash.com/photo-1497215842964-222b430dc094?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Veil',
        artist: 'Lunar Echo',
        language: 'English',
        source: 'Free Music',
        audioUrl: 'https://file-examples.com/wp-content/uploads/2017/11/file_example_MP3_2MG.mp3',
        thumbnailUrl: 'https://images.unsplash.com/photo-1488372765830-1f3fd75c52c9?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Silent Signal',
        artist: 'Dark Circuit',
        language: 'Indonesia',
        source: 'YouTube',
        audioUrl: 'https://file-examples.com/wp-content/uploads/2017/11/file_example_MP3_1MG.mp3',
        thumbnailUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=500&q=80',
      ),
    ],
  ),
  MusicMood(
    name: 'Marah',
    description: 'Beat kuat untuk mood marah atau penuh energi yang ingin disalurkan.',
    imagePath: 'assets/image/marah.png',
    color: const Color(0xFFDF7B7B),
    tracks: [
      const MusicTrack(
        title: 'Rage Mode',
        artist: 'Fury Lab',
        language: 'English',
        source: 'Spotify',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-11.mp3',
        thumbnailUrl: 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Firewire',
        artist: 'Voltage',
        language: 'Indonesia',
        source: 'YouTube Music',
        audioUrl: 'https://samplelib.com/lib/preview/mp3/sample-3s.mp3',
        thumbnailUrl: 'https://images.unsplash.com/photo-1516321497487-e288fb19713f?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Storm Pulse',
        artist: 'Crimson Synth',
        language: 'English',
        source: 'Apple Music',
        audioUrl: 'https://samplelib.com/lib/preview/mp3/sample-6s.mp3',
        thumbnailUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Breakout',
        artist: 'Volt Drive',
        language: 'English',
        source: 'Free Music',
        audioUrl: 'https://file-examples.com/wp-content/uploads/2017/11/file_example_MP3_5MG.mp3',
        thumbnailUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Red Alert',
        artist: 'Rage Circuit',
        language: 'Indonesia',
        source: 'YouTube',
        audioUrl: 'https://file-examples.com/wp-content/uploads/2017/11/file_example_MP3_2MG.mp3',
        thumbnailUrl: 'https://images.unsplash.com/photo-1497215842964-222b430dc094?auto=format&fit=crop&w=500&q=80',
      ),
    ],
  ),
];

class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _selectedMoodIndex = 0;
  int _selectedLanguageIndex = 0;
  MusicTrack? _currentTrack;
  bool _isPlaying = false;
  bool _isLoading = true;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // Compute a darker and lighter variant for a base color
  Map<String, Color> _colorVariants(Color base) {
    final h = HSLColor.fromColor(base);
    final light = h.withLightness((h.lightness + 0.22).clamp(0.0, 1.0)).toColor();
    final dark = h.withLightness((h.lightness - 0.14).clamp(0.0, 1.0)).toColor();
    return {'light': light, 'dark': dark};
  }

  @override
  void initState() {
    super.initState();
    _initializeAudioPlayer();
    _loadLastMood();
  }

  void _initializeAudioPlayer() {
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
    _audioPlayer.setVolume(1.0);

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      if (!mounted) return;
      setState(() {
        _totalDuration = duration;
      });
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (!mounted) return;
      setState(() {
        _currentPosition = position;
      });
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (!mounted) return;
      setState(() {
        _isPlaying = false;
        _currentPosition = _totalDuration;
      });
    });
  }

  Future<void> _loadLastMood() async {
    try {
      final result = await MoodService.fetchMoods();
      if (result['success'] == true && result['data'] != null) {
        final List moodsData = result['data'] as List;
        if (moodsData.isNotEmpty) {
          final lastMoodLabel = moodsData.first['mood_label']?.toString();
          if (lastMoodLabel != null) {
            final index = musicMoods.indexWhere(
              (m) => m.name.toLowerCase() == lastMoodLabel.toLowerCase(),
            );
            if (index != -1 && mounted) {
              setState(() {
                _selectedMoodIndex = index;
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading last mood: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  List<MusicTrack> get _visibleTracks {
    final tracks = musicMoods[_selectedMoodIndex].tracks;
    if (_selectedLanguageIndex == 0) return tracks;
    final filterLanguage = languageTabs[_selectedLanguageIndex];
    return tracks.where((track) => track.language == filterLanguage).toList();
  }

  Future<void> _playTrack(MusicTrack track) async {
    if (_currentTrack?.audioUrl == track.audioUrl) {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.resume();
      }
      return;
    }

    await _audioPlayer.stop();
    setState(() {
      _currentTrack = track;
      _isPlaying = true;
      _currentPosition = Duration.zero;
      _totalDuration = Duration.zero;
    });

    try {
      await _audioPlayer.play(UrlSource(track.audioUrl), volume: 1.0);
    } catch (e) {
      debugPrint('Audio playback error: $e');
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    }
  }

  Future<void> _togglePlayPause() async {
    if (_currentTrack == null) return;
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedMood = musicMoods[_selectedMoodIndex];
    final variants = _colorVariants(selectedMood.color);
    
    return ListenableBuilder(
      listenable: ThemeManager(),
      builder: (context, _) {
        const bgColor = Colors.white;

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            bottom: false,
            child: TweenAnimationBuilder<Color?>(
              tween: ColorTween(end: bgColor),
              duration: const Duration(milliseconds: 420),
              builder: (context, animatedBg, child) {
                return Container(
                  color: animatedBg,
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          // Header with animated gradient
                          TweenAnimationBuilder<Color?>(
                            tween: ColorTween(end: variants['dark']),
                            duration: const Duration(milliseconds: 420),
                            builder: (context, darkAnim, _) {
                              return TweenAnimationBuilder<Color?>(
                                tween: ColorTween(end: variants['light']),
                                duration: const Duration(milliseconds: 420),
                                builder: (context, lightAnim, _) {
                                  final darkColor = darkAnim ?? variants['dark']!;
                                  final lightColor = lightAnim ?? variants['light']!;
                                  return Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          lightColor,
                                          darkColor,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
                                      boxShadow: [
                                        BoxShadow(color: Colors.black12, blurRadius: 16, offset: const Offset(0, 6)),
                                      ],
                                    ),
                                    child: SafeArea(
                                      top: true,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () => Navigator.of(context).pop(),
                                                child: Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 4))]),
                                                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Halo, ${LaravelSessionService.displayName}',
                                                      style: GoogleFonts.poppins(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text('Temukan harmoni untuk hatimu', style: GoogleFonts.poppins(color: Colors.black54, fontSize: 12)),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                width: 80,
                                                height: 80,
                                                child: Image.asset(selectedMood.imagePath, fit: BoxFit.contain),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          Text('Mood Beats', style: GoogleFonts.outfit(color: Colors.black87, fontSize: 34, fontWeight: FontWeight.w800)),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          // Content
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Bagaimana perasaanmu?', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 12),
                                  _buildMoodChipsLight(),
                                  const SizedBox(height: 18),
                                  Text('Rekomendasi ${selectedMood.name}', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 12),
                                  _buildLanguageTabs(),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: _buildTrackGrid(selectedMood),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_currentTrack != null) _buildBottomPlayerLight(selectedMood),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildMoodChipsLight() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        itemCount: musicMoods.length,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final mood = musicMoods[index];
          final selected = index == _selectedMoodIndex;
          return GestureDetector(
            onTap: () => setState(() {
              _selectedMoodIndex = index;
              _selectedLanguageIndex = 0;
            }),
            child: Container(
              width: 120,
              margin: EdgeInsets.only(right: index == musicMoods.length - 1 ? 0 : 12),
              decoration: BoxDecoration(
                color: selected ? mood.color : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 4))],
                border: Border.all(color: selected ? mood.color.withOpacity(0.9) : Colors.grey.shade200, width: selected ? 1.5 : 1),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mood.name, style: GoogleFonts.poppins(color: selected ? Colors.white : Colors.black87, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Align(alignment: Alignment.bottomRight, child: Image.asset(mood.imagePath, width: 40, height: 40)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLanguageTabs() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(languageTabs.length, (index) {
        final active = index == _selectedLanguageIndex;
        return ChoiceChip(
          label: Text(languageTabs[index], style: GoogleFonts.poppins(color: active ? Colors.white : Colors.black87, fontSize: 12, fontWeight: FontWeight.w600)),
          selected: active,
          onSelected: (_) => setState(() => _selectedLanguageIndex = index),
          selectedColor: Theme.of(context).primaryColor,
          backgroundColor: Colors.grey.shade200,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        );
      }),
    );
  }

  Widget _buildTrackGrid(MusicMood mood) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_visibleTracks.isEmpty) {
      return Center(child: Text('Tidak ada lagu di kategori ini.', style: GoogleFonts.poppins(color: Colors.black54)));
    }

    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 140, top: 6),
      physics: const BouncingScrollPhysics(),
      itemCount: _visibleTracks.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, index) => _buildTrackGridCard(_visibleTracks[index], mood),
    );
  }

  Widget _buildTrackGridCard(MusicTrack track, MusicMood mood) {
    final isCurrent = _currentTrack?.audioUrl == track.audioUrl;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => _playTrack(track),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      track.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(color: Colors.grey.shade200),
                    ),
                  ),
                  if (track.trending)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text('Trending', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.black87)),
                      ),
                    ),
                  if (!isCurrent)
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(color: Colors.white70, shape: BoxShape.circle),
                        child: const Icon(Icons.play_arrow, color: Colors.black87, size: 20),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(track.title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Text(track.artist, style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: mood.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(track.language, style: GoogleFonts.poppins(fontSize: 10, color: mood.color, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(track.source, style: GoogleFonts.poppins(fontSize: 10, color: Colors.black45), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPlayerLight(MusicMood selectedMood) {
    if (_currentTrack == null) return const SizedBox.shrink();
    final progress = _totalDuration.inMilliseconds > 0 ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds : 0.0;

    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(value: progress, color: selectedMood.color, backgroundColor: Colors.grey.shade200, minHeight: 4),
            const SizedBox(height: 8),
            Row(
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(_currentTrack!.thumbnailUrl, width: 48, height: 48, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(width: 48, height: 48, color: Colors.grey.shade200))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_currentTrack!.title, style: GoogleFonts.outfit(fontWeight: FontWeight.w700)), Text(_currentTrack!.artist, style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54))])),
                IconButton(onPressed: _togglePlayPause, icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill, color: selectedMood.color, size: 36)),
                IconButton(
                  onPressed: () async {
                    await _audioPlayer.stop();
                    if (!mounted) return;
                    setState(() {
                      _currentTrack = null;
                      _isPlaying = false;
                      _currentPosition = Duration.zero;
                      _totalDuration = Duration.zero;
                    });
                  },
                  icon: const Icon(Icons.close, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
