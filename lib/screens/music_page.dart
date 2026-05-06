import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:audioplayers/audioplayers.dart';
import '../services/laravel_session_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard_page.dart';

// ============================================================
// Model Data
// ============================================================
class MusicCategory {
  final String name;
  final String imagePath;
  final Color color;
  final List<MusicTrack> tracks;

  const MusicCategory({
    required this.name,
    required this.imagePath,
    required this.color,
    required this.tracks,
  });
}

class MusicTrack {
  final String title;
  final String artist;
  final String url;
  final String imagePath;
  final Color color;

  const MusicTrack({
    required this.title,
    required this.artist,
    required this.url,
    required this.imagePath,
    required this.color,
  });
}

// ============================================================
// Data Musik
// ============================================================
const _base = 'https://archive.org/download/calm-relaxing-piano-collection/Calm%20Relaxing%20Piano%20-%20Collection%20%282020%29/';

final List<MusicCategory> musicCategories = [
  MusicCategory(
    name: 'Happy Playlist',
    imagePath: 'assets/image/senang.png',
    color: const Color(0xFFF38B42),
    tracks: const [
      MusicTrack(
        title: 'Art of life',
        artist: 'Lesfm',
        url: '${_base}01%20Max%20Richter%20-%20The%20Departure.mp3',
        imagePath: 'assets/image/senang.png',
        color: Color(0xFFF38B42),
      ),
      MusicTrack(
        title: '505',
        artist: 'Arctic Monkey',
        url: '${_base}02%20Yann%20Tiersen%20-%20Comptine%20d%27Un%20Autre%20Ete%20%28L%27Apres-Midi%29%20%28Portrait%20Version%29.mp3',
        imagePath: 'assets/image/senang.png',
        color: Color(0xFF8B5B29),
      ),
      MusicTrack(
        title: 'Rude',
        artist: 'MAGIC!',
        url: '${_base}03%20Olga%20Scheps%20-%20Una%20mattina.mp3',
        imagePath: 'assets/image/senang.png',
        color: Color(0xFF704A20),
      ),
    ],
  ),
  MusicCategory(
    name: 'Neutral Playlist',
    imagePath: 'assets/image/biasa.png',
    color: const Color(0xFF63B87A),
    tracks: const [
      MusicTrack(
        title: 'Serein',
        artist: 'Dmitry Evgrafov',
        url: '${_base}05%20Dmitry%20Evgrafov%20-%20Serein.mp3',
        imagePath: 'assets/image/biasa.png',
        color: Color(0xFF63B87A),
      ),
    ],
  ),
  MusicCategory(
    name: 'Sad Playlist',
    imagePath: 'assets/image/sedih.png',
    color: const Color(0xFF334B8F),
    tracks: const [
      MusicTrack(
        title: 'Roscian',
        artist: 'Agnes Obel',
        url: '${_base}08%20Agnes%20Obel%20-%20Roscian.mp3',
        imagePath: 'assets/image/sedih.png',
        color: Color(0xFF334B8F),
      ),
    ],
  ),
  MusicCategory(
    name: 'Angry Playlist',
    imagePath: 'assets/image/marah.png',
    color: const Color(0xFFD44846),
    tracks: const [
      MusicTrack(
        title: 'Sleep Is Coming',
        artist: 'Edvard Kravchuk',
        url: '${_base}60%20Edvard%20Kravchuk%20-%20Sleep%20Is%20Coming.mp3',
        imagePath: 'assets/image/marah.png',
        color: Color(0xFFD44846),
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
  int? _currentCategoryIndex;
  int? _currentTrackIndex;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });

    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => _totalDuration = d);
    });

    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) setState(() => _currentPosition = p);
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _currentPosition = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playTrack(int catIdx, int trackIdx) async {
    final track = musicCategories[catIdx].tracks[trackIdx];
    String url = track.url;
    if (kIsWeb) url = 'https://corsproxy.io/?$url';

    try {
      if (_currentCategoryIndex == catIdx && _currentTrackIndex == trackIdx) {
        if (_isPlaying) {
          await _audioPlayer.pause();
        } else {
          await _audioPlayer.resume();
        }
        return;
      }

      setState(() {
        _isLoading = true;
        _currentCategoryIndex = catIdx;
        _currentTrackIndex = trackIdx;
        _currentPosition = Duration.zero;
        _totalDuration = Duration.zero;
      });

      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memutar: ${track.title}. Cek koneksi internet.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _skipNext() {
    if (_currentCategoryIndex == null || _currentTrackIndex == null) return;
    final cat = musicCategories[_currentCategoryIndex!];
    int nextTrack = _currentTrackIndex! + 1;
    if (nextTrack >= cat.tracks.length) {
      nextTrack = 0; // loop back to start of category
    }
    _playTrack(_currentCategoryIndex!, nextTrack);
  }

  void _skipPrevious() {
    if (_currentCategoryIndex == null || _currentTrackIndex == null) return;
    final cat = musicCategories[_currentCategoryIndex!];
    int prevTrack = _currentTrackIndex! - 1;
    if (prevTrack < 0) {
      prevTrack = cat.tracks.length - 1; // loop to end
    }
    _playTrack(_currentCategoryIndex!, prevTrack);
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.inMinutes}:${two(d.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    final displayName = LaravelSessionService.displayName;
    final nameToDisplay = displayName.isNotEmpty ? displayName : 'Pengguna';

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4EE),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopSection(nameToDisplay),
            const SizedBox(height: 20),
            _buildPlaylistSection(),
            const SizedBox(height: 25),
            _buildRecentSection(),
            const SizedBox(height: 25),
            _buildTopMusicSection(),
            const SizedBox(height: 30), // Padding before bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection(String userName) {
    // Current playing track or default to first track
    final track = (_currentCategoryIndex != null && _currentTrackIndex != null)
        ? musicCategories[_currentCategoryIndex!].tracks[_currentTrackIndex!]
        : musicCategories[0].tracks[0];
    
    // Default duration strings
    final currentPosStr = _currentCategoryIndex != null ? _formatDuration(_currentPosition) : '2:38';
    final totalDurStr = _currentCategoryIndex != null && _totalDuration.inSeconds > 0 
        ? _formatDuration(_totalDuration) 
        : '3:09';

    // Calculate progress fraction
    double progress = 0.8; // default UI progress
    if (_currentCategoryIndex != null && _totalDuration.inSeconds > 0) {
      progress = _currentPosition.inSeconds / _totalDuration.inSeconds;
      progress = progress.clamp(0.0, 1.0);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 25),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF5A6F43), // dark olive green
            Color(0xFF86A562), // mid green
            Color(0xFFC4DCAA), // light sage green
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Welcome Back!',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            userName,
            style: GoogleFonts.poppins(
              color: const Color(0xFFA1F54B), // Lime green text
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 35),
          // Player Card (Glassmorphism effect)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDECB5), // Beige color
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          track.imagePath,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.music_note, color: Colors.orange),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.title,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            track.artist,
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _skipPrevious,
                      child: const Icon(Icons.skip_previous, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        if (_currentCategoryIndex == null) {
                          _playTrack(0, 0); // Play first track by default
                        } else {
                          if (_isPlaying) {
                            _audioPlayer.pause();
                          } else {
                            _audioPlayer.resume();
                          }
                        }
                      },
                      child: Icon(
                        _isLoading 
                            ? Icons.hourglass_empty 
                            : (_isPlaying ? Icons.pause : Icons.play_arrow), 
                        color: Colors.white, 
                        size: 30
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _skipNext,
                      child: const Icon(Icons.skip_next, color: Colors.white, size: 30),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(currentPosStr, style: GoogleFonts.poppins(color: Colors.white, fontSize: 11)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(totalDurStr, style: GoogleFonts.poppins(color: Colors.white, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Playlist',
            style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildPlaylistCard(0), // Happy
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPlaylistCard(1), // Neutral
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPlaylistCard(2), // Sad
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPlaylistCard(3), // Angry
              ),
            ],
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildPlaylistCard(int catIdx) {
    final cat = musicCategories[catIdx];
    return GestureDetector(
      onTap: () {
        if (cat.tracks.isNotEmpty) {
          _playTrack(catIdx, 0); // Play first track of this category
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: cat.color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFFDECB5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(7.0),
                child: Image.asset(
                  cat.imagePath,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.music_note, color: Colors.orange),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                cat.name,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSection() {
    final recentTracks = musicCategories[0].tracks; // Art of life, 505, Rude
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent',
            style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 15),
          ...recentTracks.asMap().entries.map((entry) {
            int idx = entry.key;
            MusicTrack track = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildRecentCard(0, idx, track),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecentCard(int catIdx, int trackIdx, MusicTrack track) {
    bool isCurrent = _currentCategoryIndex == catIdx && _currentTrackIndex == trackIdx;
    
    return GestureDetector(
      onTap: () => _playTrack(catIdx, trackIdx),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: track.color,
          borderRadius: BorderRadius.circular(16),
          border: isCurrent ? Border.all(color: Colors.white, width: 2) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFDECB5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  track.imagePath,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.music_note, color: Colors.orange),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.artist,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
              Text(
                isCurrent && _totalDuration.inSeconds > 0 ? _formatDuration(_totalDuration) : 
                (trackIdx == 0 ? '3:09' : (trackIdx == 1 ? '4:13' : '3:44')),
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            if (isCurrent && _isPlaying)
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Icon(Icons.equalizer, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopMusicSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        'Your top music',
        style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

}