import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/music_player_manager.dart';
import '../screens/music_page.dart';

class MiniPlayerWidget extends StatefulWidget {
  const MiniPlayerWidget({super.key});

  @override
  State<MiniPlayerWidget> createState() => _MiniPlayerWidgetState();
}

class _MiniPlayerWidgetState extends State<MiniPlayerWidget> {
  final MusicPlayerManager _playerManager = MusicPlayerManager();

  @override
  void initState() {
    super.initState();
    _playerManager.addListener(_onPlayerStateChanged);
  }

  void _onPlayerStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _playerManager.removeListener(_onPlayerStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTrack = _playerManager.currentTrack;
    if (currentTrack == null) return const SizedBox.shrink();

    final isPlaying = _playerManager.isPlaying;
    final currentPosition = _playerManager.currentPosition;
    final totalDuration = _playerManager.totalDuration;
    
    final progress = totalDuration.inMilliseconds > 0 
        ? currentPosition.inMilliseconds / totalDuration.inMilliseconds 
        : 0.0;

    // Map mood name to color
    Color themeColor = const Color(0xFF2E7D32);
    for (final mood in musicMoods) {
      if (mood.tracks.any((t) => t.audioUrl == currentTrack.audioUrl)) {
        themeColor = mood.color;
        break;
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MusicPage()),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                color: themeColor,
                backgroundColor: Colors.grey.shade200,
                minHeight: 3,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        currentTrack.thumbnailUrl,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          width: 40,
                          height: 40,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.music_note, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentTrack.title,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currentTrack.artist,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await _playerManager.togglePlayPause();
                      },
                      icon: Icon(
                        isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                        color: themeColor,
                        size: 32,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () async {
                        await _playerManager.stopTrack();
                      },
                      icon: const Icon(Icons.close, color: Colors.black54, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
