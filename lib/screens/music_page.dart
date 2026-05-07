import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../services/laravel_session_service.dart';
import '../services/mood_service.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================
// Model Data
// ============================================================
class MusicMood {
  final String name;
  final String description;
  final String imagePath;
  final Color color;
  final List<YoutubeTrack> tracks;

  const MusicMood({
    required this.name,
    required this.description,
    required this.imagePath,
    required this.color,
    required this.tracks,
  });
}

class YoutubeTrack {
  final String title;
  final String artist;
  final String videoId;
  final String thumbnailUrl;

  const YoutubeTrack({
    required this.title,
    required this.artist,
    required this.videoId,
    required this.thumbnailUrl,
  });
}

// ============================================================
// Music Data (YouTube-based)
// ============================================================
final List<MusicMood> musicMoods = [
  MusicMood(
    name: 'Senang',
    description: 'Energi positif & keceriaan',
    imagePath: 'assets/image/senang.png',
    color: const Color(0xFFFFB347),
    tracks: [
      const YoutubeTrack(
        title: 'Happy',
        artist: 'Pharrell Williams',
        videoId: 'y6Sxv-sUYtM',
        thumbnailUrl: 'https://img.youtube.com/vi/y6Sxv-sUYtM/hqdefault.jpg',
      ),
      const YoutubeTrack(
        title: 'Sugar',
        artist: 'Maroon 5',
        videoId: '09R8_2nJtjg',
        thumbnailUrl: 'https://img.youtube.com/vi/09R8_2nJtjg/hqdefault.jpg',
      ),
      const YoutubeTrack(
        title: "Can't Stop The Feeling",
        artist: 'Justin Timberlake',
        videoId: 'ru0K8uYEZWw',
        thumbnailUrl: 'https://img.youtube.com/vi/ru0K8uYEZWw/hqdefault.jpg',
      ),
      const YoutubeTrack(
        title: 'Best Day Of My Life',
        artist: 'American Authors',
        videoId: 'Y66j_BUCBMY',
        thumbnailUrl: 'https://img.youtube.com/vi/Y66j_BUCBMY/hqdefault.jpg',
      ),
    ],
  ),
  MusicMood(
    name: 'Antusias',
    description: 'Semangat tinggi & gairah',
    imagePath: 'assets/image/antusias.png',
    color: const Color(0xFFFF6B6B),
    tracks: [
      const YoutubeTrack(
        title: 'On Top of the World',
        artist: 'Imagine Dragons',
        videoId: 'w5tWYm66pBA',
        thumbnailUrl: 'https://img.youtube.com/vi/w5tWYm66pBA/hqdefault.jpg',
      ),
      const YoutubeTrack(
        title: 'Roar',
        artist: 'Katy Perry',
        videoId: 'CevxZvSJLk8',
        thumbnailUrl: 'https://img.youtube.com/vi/CevxZvSJLk8/hqdefault.jpg',
      ),
      const YoutubeTrack(
        title: 'Believer',
        artist: 'Imagine Dragons',
        videoId: '7wtfhZwyrcc',
        thumbnailUrl: 'https://img.youtube.com/vi/7wtfhZwyrcc/hqdefault.jpg',
      ),
      const YoutubeTrack(
        title: 'High Hopes',
        artist: 'Panic! At The Disco',
        videoId: 'IPXIgEAGe4U',
        thumbnailUrl: 'https://img.youtube.com/vi/IPXIgEAGe4U/hqdefault.jpg',
      ),
    ],
  ),
  MusicMood(
    name: 'Netral',
    description: 'Ketenangan & keseimbangan',
    imagePath: 'assets/image/biasa.png',
    color: const Color(0xFF4ECDC4),
    tracks: [
      const YoutubeTrack(
        title: 'Counting Stars',
        artist: 'OneRepublic',
        videoId: 'hT_nvWreIhg',
        thumbnailUrl: 'https://img.youtube.com/vi/hT_nvWreIhg/hqdefault.jpg',
      ),
      const YoutubeTrack(
        title: 'Perfect',
        artist: 'Ed Sheeran',
        videoId: '2Vv-BfVoq4g',
        thumbnailUrl: 'https://img.youtube.com/vi/2Vv-BfVoq4g/hqdefault.jpg',
      ),
      const YoutubeTrack(
        title: 'A Sky Full of Stars',
        artist: 'Coldplay',
        videoId: 'VPRjCeUt0_8',
        thumbnailUrl: 'https://img.youtube.com/vi/VPRjCeUt0_8/hqdefault.jpg',
      ),
      const YoutubeTrack(
        title: 'Paradise',
        artist: 'Coldplay',
        videoId: '1G4isv_Fylg',
        thumbnailUrl: 'https://img.youtube.com/vi/1G4isv_Fylg/hqdefault.jpg',
      ),
    ],
  ),
  MusicMood(
    name: 'Terkejut',
    description: 'Keajaiban & kejutan',
    imagePath: 'assets/image/terkejut.png',
    color: const Color(0xFFA29BFE),
    tracks: [
      const YoutubeTrack(
        title: "Don't Know Why",
        artist: 'Norah Jones',
        videoId: 'tO4dxvguQDk',
        thumbnailUrl: 'https://img.youtube.com/vi/tO4dxvguQDk/hqdefault.jpg',
      ),
      const YoutubeTrack(
        title: 'Better Together',
        artist: 'Jack Johnson',
        videoId: 'nL_S6uBvU8s',
        thumbnailUrl: 'https://img.youtube.com/vi/nL_S6uBvU8s/hqdefault.jpg',
      ),
      const YoutubeTrack(
        title: 'Thinking Out Loud',
        artist: 'Ed Sheeran',
        videoId: 'lp-EO5I60KA',
        thumbnailUrl: 'https://img.youtube.com/vi/lp-EO5I60KA/hqdefault.jpg',
      ),
    ],
  ),
  MusicMood(
    name: 'Sedih',
    description: 'Kedamaian & refleksi diri',
    imagePath: 'assets/image/sedih.png',
    color: const Color(0xFF6C5CE7),
    tracks: [
      const YoutubeTrack(
        title: 'A Thousand Years (Piano Version)',
        artist: 'The Piano Guys',
        videoId: '9mQk70xshXk',
        thumbnailUrl: 'https://img.youtube.com/vi/9mQk70xshXk/hqdefault.jpg',
      ),
      const YoutubeTrack(
        title: 'Somewhere Only We Know (Piano Instrumental)',
        artist: 'Piano Novel',
        videoId: 'V07p7D48Eio',
        thumbnailUrl: 'https://img.youtube.com/vi/V07p7D48Eio/hqdefault.jpg',
      ),
      const YoutubeTrack(
        title: 'River Flows in You (Piano Version)',
        artist: 'Yiruma',
        videoId: '7maJOI3QMu0',
        thumbnailUrl: 'https://img.youtube.com/vi/7maJOI3QMu0/hqdefault.jpg',
      ),
      const YoutubeTrack(
        title: "She's The One (Piano Version)",
        artist: 'Robbie Williams (Piano)',
        videoId: 'hI_o_pS3-5Y',
        thumbnailUrl: 'https://img.youtube.com/vi/hI_o_pS3-5Y/hqdefault.jpg',
      ),
      const YoutubeTrack(
        title: 'Fix You (Piano Version)',
        artist: 'Coldplay (Piano)',
        videoId: 'k4V3Mo61fJM',
        thumbnailUrl: 'https://img.youtube.com/vi/k4V3Mo61fJM/hqdefault.jpg',
      ),
      const YoutubeTrack(
        title: 'Photograph (Acoustic Instrumental)',
        artist: 'Ed Sheeran (Acoustic)',
        videoId: 'rS3N5V570Vw',
        thumbnailUrl: 'https://img.youtube.com/vi/rS3N5V570Vw/hqdefault.jpg',
      ),
    ],
  ),
  MusicMood(
    name: 'Takut',
    description: 'Kenyamanan & ketenangan',
    imagePath: 'assets/image/takut.png',
    color: const Color(0xFF535C68),
    tracks: [
      const YoutubeTrack(
        title: 'Skinny Love',
        artist: 'Birdy',
        videoId: 'aNzCDt26_fA',
        thumbnailUrl: 'https://img.youtube.com/vi/aNzCDt26_fA/hqdefault.jpg',
      ),
      const YoutubeTrack(
        title: 'Bellyache',
        artist: 'Billie Eilish',
        videoId: 'D8YmF6L8zLg',
        thumbnailUrl: 'https://img.youtube.com/vi/D8YmF6L8zLg/hqdefault.jpg',
      ),
      const YoutubeTrack(
        title: 'Lovely',
        artist: 'Billie Eilish, Khalid',
        videoId: 'V1Pl8CzNzCw',
        thumbnailUrl: 'https://img.youtube.com/vi/V1Pl8CzNzCw/hqdefault.jpg',
      ),
    ],
  ),
  MusicMood(
    name: 'Marah',
    description: 'Pelepasan emosi & energi',
    imagePath: 'assets/image/marah.png',
    color: const Color(0xFFD63031),
    tracks: [
      const YoutubeTrack(
        title: 'EEEE A',
        artist: 'DJ Remix Viral',
        videoId: 'G9rYshkGZ5I',
        thumbnailUrl: 'https://img.youtube.com/vi/G9rYshkGZ5I/hqdefault.jpg',
      ),
      const YoutubeTrack(
        title: 'Mejikuhibiniu',
        artist: 'DJ Remix Viral',
        videoId: 'S0AovI_pGVE',
        thumbnailUrl: 'https://img.youtube.com/vi/S0AovI_pGVE/hqdefault.jpg',
      ),
      const YoutubeTrack(
        title: 'Bintang 5',
        artist: 'DJ Remix Viral',
        videoId: 'W56E-fE90F4',
        thumbnailUrl: 'https://img.youtube.com/vi/W56E-fE90F4/hqdefault.jpg',
      ),
      const YoutubeTrack(
        title: 'Malu Malu',
        artist: 'DJ Remix Viral',
        videoId: 'Q3jY-X6C09A',
        thumbnailUrl: 'https://img.youtube.com/vi/Q3jY-X6C09A/hqdefault.jpg',
      ),
      const YoutubeTrack(
        title: 'So Asu',
        artist: 'DJ Remix Viral',
        videoId: 'mN7S1fDInqY',
        thumbnailUrl: 'https://img.youtube.com/vi/mN7S1fDInqY/hqdefault.jpg',
      ),
      const YoutubeTrack(
        title: 'Sency',
        artist: 'DJ Remix Viral',
        videoId: 'vV66X_l-z-g',
        thumbnailUrl: 'https://img.youtube.com/vi/vV66X_l-z-g/hqdefault.jpg',
      ),
    ],
  ),
];

// ============================================================
// MusicPage Widget
// ============================================================
class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  late YoutubePlayerController _controller;
  int _selectedMoodIndex = 0;
  YoutubeTrack? _currentTrack;
  bool _isPlayerVisible = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _loadLastMood();
  }

  void _initializePlayer() {
    _controller = YoutubePlayerController(
      initialVideoId: '',
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: false,
        useHybridComposition: true,
      ),
    );
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
            if (index != -1) {
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
    _controller.dispose();
    super.dispose();
  }

  void _playTrack(YoutubeTrack track) {
    setState(() {
      _currentTrack = track;
      _isPlayerVisible = true;
    });
    _controller.load(track.videoId.trim());
  }

  @override
  Widget build(BuildContext context) {
    final displayName = LaravelSessionService.displayName;
    final userName = displayName.isNotEmpty ? displayName : 'Sobat Emora';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(userName),
              SliverToBoxAdapter(
                child: _isLoading
                    ? const SizedBox(
                        height: 300,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF768266),
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          _buildMoodSelector(),
                          _buildTrackList(),
                          const SizedBox(height: 120),
                        ],
                      ),
              ),
            ],
          ),
          if (_isPlayerVisible) _buildMiniPlayer(),
        ],
      ),
    );
  }

  // ─── App Bar ───────────────────────────────────────────────
  Widget _buildSliverAppBar(String userName) {
    final selectedMood = musicMoods[_selectedMoodIndex];
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: selectedMood.color,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.24),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 18),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        title: Text(
          'Mood Beats',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 24,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.26),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    selectedMood.color,
                    selectedMood.color.withOpacity(0.6),
                  ],
                ),
              ),
            ),
            // Decorative mood image
            Positioned(
              right: -20,
              bottom: -20,
              child: Opacity(
                opacity: 0.3,
                child: Image.asset(
                  selectedMood.imagePath,
                  width: 180,
                  height: 180,
                ),
              ),
            ),
            // Greeting text
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 80, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, $userName',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Temukan harmoni untuk hatimu',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Mini Player ────────────────────────────────────────────
  Widget _buildMiniPlayer() {
    final selectedMood = musicMoods[_selectedMoodIndex];
    return Positioned(
      left: 16,
      right: 16,
      bottom: 24,
      child: Container(
        height: 85,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // Embedded YouTube player (compact)
            Container(
              width: 85,
              height: 85,
              color: Colors.black,
              child: YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: selectedMood.color,
                onReady: () {},
              ),
            ),
            const SizedBox(width: 12),
            // Track info
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentTrack?.title ?? '',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _currentTrack?.artist ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Close button
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              onPressed: () {
                setState(() {
                  _isPlayerVisible = false;
                  _controller.pause();
                });
              },
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  // ─── Mood Selector ──────────────────────────────────────────
  Widget _buildMoodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Bagaimana perasaanmu?',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3436),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: musicMoods.length,
            itemBuilder: (context, index) {
              final mood = musicMoods[index];
              final isSelected = _selectedMoodIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMoodIndex = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutQuint,
                  width: 85,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? mood.color : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? mood.color.withOpacity(0.3)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        mood.imagePath,
                        width: 42,
                        height: 42,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        mood.name,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── Track List ─────────────────────────────────────────────
  Widget _buildTrackList() {
    final selectedMood = musicMoods[_selectedMoodIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: selectedMood.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Rekomendasi ${selectedMood.name}',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: selectedMood.tracks.length,
          itemBuilder: (context, index) {
            final track = selectedMood.tracks[index];
            final isPlaying =
                _currentTrack?.videoId == track.videoId &&
                    _isPlayerVisible;

            return GestureDetector(
              onTap: () => _playTrack(track),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isPlaying
                      ? selectedMood.color.withOpacity(0.06)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: isPlaying
                      ? Border.all(
                          color: selectedMood.color.withOpacity(0.4),
                          width: 1.5)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  leading: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Thumbnail
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: NetworkImage(track.thumbnailUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Play/Pause overlay
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                  title: Text(
                    track.title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isPlaying
                          ? selectedMood.color
                          : const Color(0xFF2D3436),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    track.artist,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: selectedMood.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.music_note_rounded,
                      size: 18,
                      color: selectedMood.color,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}