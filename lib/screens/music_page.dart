import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart' as yt show YoutubePlayerController, YoutubePlayerFlags, YoutubePlayerBuilder, YoutubePlayer;
import 'package:url_launcher/url_launcher_string.dart';
import '../services/mood_service.dart';
import '../services/laravel_session_service.dart';
import '../services/theme_manager.dart';
import '../services/music_player_manager.dart';
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

final List<MusicMood> musicMoods = [
  MusicMood(
    name: 'Senang',
    description: 'Beat ceria yang cocok untuk produktivitas kampus.',
    imagePath: 'assets/image/senang.png',
    color: const Color(0xFFFFB347),
    tracks: [
      const MusicTrack(
        title: 'Fade',
        artist: 'Alan Walker',
        language: 'Indonesia',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=60ItHLz5WEA',
        thumbnailUrl: 'https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?auto=format&fit=crop&w=500&q=80',
        trending: true,
      ),
      const MusicTrack(
        title: 'Believer',
        artist: 'Imagine Dragons',
        language: 'Indonesia',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=7wtfhZwyrcc',
        thumbnailUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Havana',
        artist: 'Camila Cabello',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=HCjNJDNzw8Y',
        thumbnailUrl: 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Blinding Lights',
        artist: 'The Weeknd',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=fHI8X4OXluQ',
        thumbnailUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Higher Power',
        artist: 'Coldplay',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=s7L2PVdrb_8',
        thumbnailUrl: 'https://images.unsplash.com/photo-1488372765830-1f3fd75c52c9?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Can\'t Stop the Feeling',
        artist: 'Justin Timberlake',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=ru0K8uYEZWw',
        thumbnailUrl: 'https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Good Life',
        artist: 'OneRepublic',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=jZhQOvvV45w',
        thumbnailUrl: 'https://images.unsplash.com/photo-1517816743773-6e0fd518b4a6?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Sugar',
        artist: 'Maroon 5',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=09R8_2nJtjg',
        thumbnailUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Uptown Funk',
        artist: 'Bruno Mars',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=OPf0YbXqDm0',
        thumbnailUrl: 'https://images.unsplash.com/photo-1504384308090-c894ddcc538d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Shut Up and Dance',
        artist: 'Walk The Moon',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=6JCLY0Rlx6Q',
        thumbnailUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Best Day of My Life',
        artist: 'American Authors',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=Y66j_BUCBMY',
        thumbnailUrl: 'https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'I Gotta Feeling',
        artist: 'Black Eyed Peas',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=uSD4vsh1zDA',
        thumbnailUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Don\'t Worry Be Happy',
        artist: 'Bobby McFerrin',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=d-diB65scQU',
        thumbnailUrl: 'https://images.unsplash.com/photo-1488372765830-1f3fd75c52c9?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Roar',
        artist: 'Katy Perry',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=CevxZvSJLk8',
        thumbnailUrl: 'https://images.unsplash.com/photo-1517816743773-6e0fd518b4a6?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Cheap Thrills',
        artist: 'Sia',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=nYh-n7EOtMA',
        thumbnailUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Firework',
        artist: 'Katy Perry',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=QGJuMBdaqIw',
        thumbnailUrl: 'https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Cake by the Ocean',
        artist: 'DNCE',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=vWaRiD5ym74',
        thumbnailUrl: 'https://images.unsplash.com/photo-1504384308090-c894ddcc538d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Happy',
        artist: 'Pharrell Williams',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=y6Sxv-sUYtM',
        thumbnailUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Wake Me Up',
        artist: 'Avicii',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=IcrbM1l_BoI',
        thumbnailUrl: 'https://images.unsplash.com/photo-1497215842964-222b430dc094?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Counting Stars',
        artist: 'OneRepublic',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=hT_nvWreIhg',
        thumbnailUrl: 'https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?auto=format&fit=crop&w=500&q=80',
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
        title: 'Beautiful Day',
        artist: 'U2',
        language: 'Indonesia',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=aC6YVdRkNfY',
        thumbnailUrl: 'https://images.unsplash.com/photo-1517816743773-6e0fd518b4a6?auto=format&fit=crop&w=500&q=80',
        trending: true,
      ),
      const MusicTrack(
        title: 'Rise Up',
        artist: 'Andra Day',
        language: 'Indonesia',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=k_7b7bIZAyk',
        thumbnailUrl: 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Together',
        artist: 'Sia',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=_0EZq5FHz3E',
        thumbnailUrl: 'https://images.unsplash.com/photo-1519750157634-bf64fd465a4d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Dynamite',
        artist: 'BTS',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=1ZAPwfrtAFY',
        thumbnailUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'On Top of the World',
        artist: 'Imagine Dragons',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=w5tWYmIOWGk',
        thumbnailUrl: 'https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Eye of the Tiger',
        artist: 'Survivor',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=btPJPFnesV4',
        thumbnailUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Titanium',
        artist: 'David Guetta ft. Sia',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=JRfuAukYTKg',
        thumbnailUrl: 'https://images.unsplash.com/photo-1488372765830-1f3fd75c52c9?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Can\'t Hold Us',
        artist: 'Macklemore & Ryan Lewis',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=2zNSgSzhBfM',
        thumbnailUrl: 'https://images.unsplash.com/photo-1517816743773-6e0fd518b4a6?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Hall of Fame',
        artist: 'The Script ft. will.i.am',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=mk48xRzuNvA',
        thumbnailUrl: 'https://images.unsplash.com/photo-1504384308090-c894ddcc538d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'High Hopes',
        artist: 'Panic! At The Disco',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=IPXIgEAGe4U',
        thumbnailUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Whatever It Takes',
        artist: 'Imagine Dragons',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=gOsMchLQwto',
        thumbnailUrl: 'https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Don\'t Stop Me Now',
        artist: 'Queen',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=HgzGwKwLmgM',
        thumbnailUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Remember the Name',
        artist: 'Fort Minor',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=72QKcF15ChM',
        thumbnailUrl: 'https://images.unsplash.com/photo-1488372765830-1f3fd75c52c9?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Stronger',
        artist: 'Kanye West',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=PsO6ZnUZI0g',
        thumbnailUrl: 'https://images.unsplash.com/photo-1517816743773-6e0fd518b4a6?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'The Man',
        artist: 'Aloe Blacc',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=Sv6dMFF_yts',
        thumbnailUrl: 'https://images.unsplash.com/photo-1504384308090-c894ddcc538d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Fight Song',
        artist: 'Rachel Platten',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=xo1VInw-SKc',
        thumbnailUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Unstoppable',
        artist: 'Sia',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=cxjvTXoHc1Y',
        thumbnailUrl: 'https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Good Feeling',
        artist: 'Flo Rida',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=2S24-y0Ij3Y',
        thumbnailUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Uprising',
        artist: 'Muse',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=w8KQmps-Sog',
        thumbnailUrl: 'https://images.unsplash.com/photo-1488372765830-1f3fd75c52c9?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Pump It',
        artist: 'Black Eyed Peas',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=ZaI2IlHwmgQ',
        thumbnailUrl: 'https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?auto=format&fit=crop&w=500&q=80',
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
        title: 'Heat Waves',
        artist: 'Glass Animals',
        language: 'Indonesia',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=0yW7w8F2TVA',
        thumbnailUrl: 'https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Memories',
        artist: 'Maroon 5',
        language: 'Indonesia',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=NrgmdOz227I',
        thumbnailUrl: 'https://images.unsplash.com/photo-1500534623283-312aade485b7?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Midnight City',
        artist: 'M83',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=dX3k_QDnzHE',
        thumbnailUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Lose Yourself',
        artist: 'Eminem',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=_Yhyp-_hX2s',
        thumbnailUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Happy',
        artist: 'Pharrell Williams',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=ZbZSe6N_BXs',
        thumbnailUrl: 'https://images.unsplash.com/photo-1488372765830-1f3fd75c52c9?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Chasing Cars',
        artist: 'Snow Patrol',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=GemKqzILV4w',
        thumbnailUrl: 'https://images.unsplash.com/photo-1517816743773-6e0fd518b4a6?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Let Her Go',
        artist: 'Passenger',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=RBumgq5yVrA',
        thumbnailUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Somewhere Only We Know',
        artist: 'Keane',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=oEu4O90YJRI',
        thumbnailUrl: 'https://images.unsplash.com/photo-1488372765830-1f3fd75c52c9?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'The Scientist',
        artist: 'Coldplay',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=RB-RcX5DS5A',
        thumbnailUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Yellow',
        artist: 'Coldplay',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=yKNxeF4KMsY',
        thumbnailUrl: 'https://images.unsplash.com/photo-1516321497487-e288fb19713f?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Stay',
        artist: 'Rihanna ft. Mikky Ekko',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=JF8BRvqGCNs',
        thumbnailUrl: 'https://images.unsplash.com/photo-1497215842964-222b430dc094?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Happier',
        artist: 'Marshmello ft. Bastille',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=m7Bc3pLyij0',
        thumbnailUrl: 'https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Summertime Sadness',
        artist: 'Lana Del Rey',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=nVjsGKrE6E8',
        thumbnailUrl: 'https://images.unsplash.com/photo-1504384308090-c894ddcc538d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Sweater Weather',
        artist: 'The Neighbourhood',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=GCdwKhTtNNw',
        thumbnailUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Breathe Me',
        artist: 'Sia',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=ghPcYqn0p4Y',
        thumbnailUrl: 'https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'River',
        artist: 'Leon Bridges',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=K7-BN2m3Wm4',
        thumbnailUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Budapest',
        artist: 'George Ezra',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=VHrLPs3_1Fs',
        thumbnailUrl: 'https://images.unsplash.com/photo-1488372765830-1f3fd75c52c9?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Skinny Love',
        artist: 'Bon Iver',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=ssdgFoHLwnk',
        thumbnailUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Sunflower',
        artist: 'Post Malone & Swae Lee',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=ApXoWvfEYVU',
        thumbnailUrl: 'https://images.unsplash.com/photo-1497215842964-222b430dc094?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Sunday Morning',
        artist: 'Maroon 5',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=S4_4sLFoE7I',
        thumbnailUrl: 'https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?auto=format&fit=crop&w=500&q=80',
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
        title: 'Senorita',
        artist: 'Shawn Mendes & Camila Cabello',
        language: 'Indonesia',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=PCgv5O6lddI',
        thumbnailUrl: 'https://images.unsplash.com/photo-1522770179533-24471fcdba45?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Someone Like You',
        artist: 'Adele',
        language: 'Indonesia',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=hLQl3WQQoQ0',
        thumbnailUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Can\'t Stop the Feeling',
        artist: 'Justin Timberlake',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=Qz1cMZBtBko',
        thumbnailUrl: 'https://images.unsplash.com/photo-1488372765830-1f3fd75c52c9?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Thunder',
        artist: 'Imagine Dragons',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=fKopy74weus',
        thumbnailUrl: 'https://images.unsplash.com/photo-1529070538774-1843cb3265df?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Radioactive',
        artist: 'Imagine Dragons',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=ktvTqknDobU',
        thumbnailUrl: 'https://images.unsplash.com/photo-1497215842964-222b430dc094?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Say You Love Me',
        artist: 'Jessie Ware',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=OQjE9mz4Sjs',
        thumbnailUrl: 'https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Fix You',
        artist: 'Coldplay',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=k4V3Mo61fJM',
        thumbnailUrl: 'https://images.unsplash.com/photo-1488372765830-1f3fd75c52c9?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'When I Was Your Man',
        artist: 'Bruno Mars',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=ekzHIouo8Q4',
        thumbnailUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Stay With Me',
        artist: 'Sam Smith',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=pB-5XG-DbAA',
        thumbnailUrl: 'https://images.unsplash.com/photo-1504384308090-c894ddcc538d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'All of Me',
        artist: 'John Legend',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=450p7goxZqg',
        thumbnailUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Back to December',
        artist: 'Taylor Swift',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=QUwxKWT6m7U',
        thumbnailUrl: 'https://images.unsplash.com/photo-1497215842964-222b430dc094?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Photograph',
        artist: 'Ed Sheeran',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=nSDgHBxUbVQ',
        thumbnailUrl: 'https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Hurt',
        artist: 'Johnny Cash',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=8AHCfZTRGiI',
        thumbnailUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Shallow',
        artist: 'Lady Gaga & Bradley Cooper',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=bo_efYhYU2A',
        thumbnailUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Wrecking Ball',
        artist: 'Miley Cyrus',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=My2FRPA3Gf8',
        thumbnailUrl: 'https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Skinny Love',
        artist: 'Bon Iver',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=ssdgFoHLwnk',
        thumbnailUrl: 'https://images.unsplash.com/photo-1504384308090-c894ddcc538d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Say Something',
        artist: 'A Great Big World & Christina Aguilera',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=-2U0Ivkn2Ds',
        thumbnailUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Too Good at Goodbyes',
        artist: 'Sam Smith',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=J_ub7Etch2U',
        thumbnailUrl: 'https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Hallelujah',
        artist: 'Leonard Cohen',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=YrLk4vdY28Q',
        thumbnailUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'All I Want',
        artist: 'Kodaline',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=mtf7hC17IBM',
        thumbnailUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Breakeven',
        artist: 'The Script',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=k8V9lYjJ2mQ',
        thumbnailUrl: 'https://images.unsplash.com/photo-1497215842964-222b430dc094?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'My Immortal',
        artist: 'Evanescence',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=5anLPw0Efmo',
        thumbnailUrl: 'https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Someone You Loved',
        artist: 'Lewis Capaldi',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=zABLecsR5UE',
        thumbnailUrl: 'https://images.unsplash.com/photo-1504384308090-c894ddcc538d?auto=format&fit=crop&w=500&q=80',
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
        title: 'Sunset Lover',
        artist: 'Petit Biscuit',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=AM6X8KX7dFw',
        thumbnailUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Electric Feel',
        artist: 'MGMT',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=mm-5HEXWfrQ',
        thumbnailUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Stolen Dance',
        artist: 'Milky Chance',
        language: 'Indonesia',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=mzvYYf1kI1o',
        thumbnailUrl: 'https://images.unsplash.com/photo-1490077471108-0cad1290d8b3?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Ocean Eyes',
        artist: 'Billie Eilish',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=8wZTLyITW1M',
        thumbnailUrl: 'https://images.unsplash.com/photo-1515871204537-7d92b94b8045?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Calm Down',
        artist: 'Rema',
        language: 'Indonesia',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=b5WaFVLZij8',
        thumbnailUrl: 'https://images.unsplash.com/photo-1516321497487-e288fb19713f?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Bad Guy',
        artist: 'Billie Eilish',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=DyDfgMOUjCI',
        thumbnailUrl: 'https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Good 4 U',
        artist: 'Olivia Rodrigo',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=gNi_6U5Pm_o',
        thumbnailUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Don\'t Start Now',
        artist: 'Dua Lipa',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=Nz-dPOjZS5Y',
        thumbnailUrl: 'https://images.unsplash.com/photo-1488372765830-1f3fd75c52c9?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Kings & Queens',
        artist: 'Ava Max',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=G7KNmW9a75Y',
        thumbnailUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Blinding Lights',
        artist: 'The Weeknd',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=fHI8X4OXluQ',
        thumbnailUrl: 'https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Starboy',
        artist: 'The Weeknd ft. Daft Punk',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=34Na4j8AVgA',
        thumbnailUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Believer',
        artist: 'Imagine Dragons',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=7wtfhZwyrcc',
        thumbnailUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Feel It Still',
        artist: 'Portugal. The Man',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=pBkHHoOIIn8',
        thumbnailUrl: 'https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Radioactive',
        artist: 'Imagine Dragons',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=ktvTqknDobU',
        thumbnailUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Happier',
        artist: 'Marshmello ft. Bastille',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=m7Bc3pLyij0',
        thumbnailUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'The Less I Know The Better',
        artist: 'Tame Impala',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=sBzrzS1Ag_g',
        thumbnailUrl: 'https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Heathens',
        artist: 'Twenty One Pilots',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=UprcpdwuwCg',
        thumbnailUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Bad Liar',
        artist: 'Imagine Dragons',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=Ih0iu80u04Y',
        thumbnailUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Bad Romance',
        artist: 'Lady Gaga',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=qrO4YZeyl0I',
        thumbnailUrl: 'https://images.unsplash.com/photo-1497215842964-222b430dc094?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Chandelier',
        artist: 'Sia',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=2vjPBrBU-TM',
        thumbnailUrl: 'https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?auto=format&fit=crop&w=500&q=80',
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
        title: 'The Nights',
        artist: 'Avicii',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=UtF6Jej8yb4',
        thumbnailUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Adventure of a Lifetime',
        artist: 'Coldplay',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=Q0oIoR9mLwc',
        thumbnailUrl: 'https://images.unsplash.com/photo-1522770179533-24471fcdba45?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Lovely',
        artist: 'Billie Eilish & Khalid',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=V1Pl8CzNzCw',
        thumbnailUrl: 'https://images.unsplash.com/photo-1488372765830-1f3fd75c52c9?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Lights',
        artist: 'Ellie Goulding',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=0NKUpo_xKyQ',
        thumbnailUrl: 'https://images.unsplash.com/photo-1497215842964-222b430dc094?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Painkiller',
        artist: 'Ruel',
        language: 'Indonesia',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=8Epl2w1tJ5w',
        thumbnailUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'The Hills',
        artist: 'The Weeknd',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=yzTuBuRdAyA',
        thumbnailUrl: 'https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Demons',
        artist: 'Imagine Dragons',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=mWRsgZuwf_8',
        thumbnailUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Bring Me to Life',
        artist: 'Evanescence',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=3YxaaGgTQYM',
        thumbnailUrl: 'https://images.unsplash.com/photo-1522770179533-24471fcdba45?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Numb',
        artist: 'Linkin Park',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=kXYiU_JCYtU',
        thumbnailUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Animals',
        artist: 'Martin Garrix',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=gCYcHz2k5x0',
        thumbnailUrl: 'https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Believer',
        artist: 'Imagine Dragons',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=7wtfhZwyrcc',
        thumbnailUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Radioactive',
        artist: 'Imagine Dragons',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=ktvTqknDobU',
        thumbnailUrl: 'https://images.unsplash.com/photo-1497215842964-222b430dc094?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Disturbia',
        artist: 'Rihanna',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=E3-5YC_oHjE',
        thumbnailUrl: 'https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Monster',
        artist: 'Imagine Dragons',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=7d3M2T5NSgA',
        thumbnailUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'In the End',
        artist: 'Linkin Park',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=eVTXPUF4Oz4',
        thumbnailUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Stressed Out',
        artist: 'Twenty One Pilots',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=pXRviuL6vMY',
        thumbnailUrl: 'https://images.unsplash.com/photo-1497215842964-222b430dc094?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Natural',
        artist: 'Imagine Dragons',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=0I647GU3Jsc',
        thumbnailUrl: 'https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Ghost Town',
        artist: 'Kanye West',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=PQmE6t4xA2w',
        thumbnailUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Seven Nation Army',
        artist: 'The White Stripes',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=0J2QdDbelmY',
        thumbnailUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Madness',
        artist: 'Muse',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=QYHxGBH6o4M',
        thumbnailUrl: 'https://images.unsplash.com/photo-1497215842964-222b430dc094?auto=format&fit=crop&w=500&q=80',
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
        title: 'Titanium',
        artist: 'David Guetta ft. Sia',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=JRfuAukYTKg',
        thumbnailUrl: 'https://images.unsplash.com/photo-1504384308090-c894ddcc538d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Turn Down for What',
        artist: 'DJ Snake & Lil Jon',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=HMUDVMiITOU',
        thumbnailUrl: 'https://images.unsplash.com/photo-1516321497487-e288fb19713f?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Animals',
        artist: 'Martin Garrix',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=gCYcHz2k5x0',
        thumbnailUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Tremor',
        artist: 'Dimitri Vegas, Martin Garrix, Like Mike',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=xIxgV1HUd3U',
        thumbnailUrl: 'https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'One More Time',
        artist: 'Daft Punk',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=FGBhQbmPwH8',
        thumbnailUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Levels',
        artist: 'Avicii',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=_ovdm2yX4MA',
        thumbnailUrl: 'https://images.unsplash.com/photo-1488372765830-1f3fd75c52c9?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Lean On',
        artist: 'Major Lazer & DJ Snake',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=YqeW9_5kURI',
        thumbnailUrl: 'https://images.unsplash.com/photo-1497215842964-222b430dc094?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Don\'t You Worry Child',
        artist: 'Swedish House Mafia',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=1y6smkh6c-0',
        thumbnailUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Scary Monsters and Nice Sprites',
        artist: 'Skrillex',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=WSeNSzJ2-Jw',
        thumbnailUrl: 'https://images.unsplash.com/photo-1504384308090-c894ddcc538d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Clarity',
        artist: 'Zedd ft. Foxes',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=IxxstCcJlsc',
        thumbnailUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'This Is What You Came For',
        artist: 'Calvin Harris ft. Rihanna',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=kOkQ4T5WO9E',
        thumbnailUrl: 'https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Wake Me Up',
        artist: 'Avicii',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=IcrbM1l_BoI',
        thumbnailUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'In the Name of Love',
        artist: 'Martin Garrix & Bebe Rexha',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=2vPuyALZJfU',
        thumbnailUrl: 'https://images.unsplash.com/photo-1488372765830-1f3fd75c52c9?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Where Are Ü Now',
        artist: 'Jack Ü & Justin Bieber',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=BiQIc7fG7X0',
        thumbnailUrl: 'https://images.unsplash.com/photo-1497215842964-222b430dc094?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Turn Up the Speakers',
        artist: 'Afrojack & Martin Garrix',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=daTjXgA8nfE',
        thumbnailUrl: 'https://images.unsplash.com/photo-1516321497487-e288fb19713f?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Reload',
        artist: 'Sebastian Ingrosso, Tommy Trash ft. John Martin',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=aKcMJZJ0bDY',
        thumbnailUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'I Could Be the One',
        artist: 'Avicii vs Nicky Romero',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=R0mt3gNwEEE',
        thumbnailUrl: 'https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Summer',
        artist: 'Calvin Harris',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=ebXbLfLACGM',
        thumbnailUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Sweet Nothing',
        artist: 'Calvin Harris ft. Florence Welch',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=1P5QOV20WqA',
        thumbnailUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=500&q=80',
      ),
      const MusicTrack(
        title: 'Get Low',
        artist: 'Dillon Francis & DJ Snake',
        language: 'English',
        source: 'YouTube',
        audioUrl: 'https://www.youtube.com/watch?v=UZ6V10XJSlo',
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
  final MusicPlayerManager _playerManager = MusicPlayerManager();
  int _selectedMoodIndex = 0;
  bool _isLoading = true;

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
    _playerManager.addListener(_onPlayerStateChanged);
    _loadLastMood();
  }

  void _onPlayerStateChanged() {
    if (mounted) {
      setState(() {});
    }
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
    _playerManager.removeListener(_onPlayerStateChanged);
    super.dispose();
  }

  List<MusicTrack> get _visibleTracks {
    return musicMoods[_selectedMoodIndex].tracks;
  }

  Future<void> _playTrack(MusicTrack track) async {
    await _playerManager.playTrack(track);
  }

  Future<void> _togglePlayPause() async {
    await _playerManager.togglePlayPause();
  }

  bool _isYouTubeTrack(MusicTrack track) {
    final url = track.audioUrl.toLowerCase();
    return url.contains('youtube.com/watch') || url.contains('youtu.be/');
  }

  String? _extractYoutubeVideoId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null;
    }
    if (uri.host.contains('youtube.com')) {
      return uri.queryParameters['v'];
    }
    return null;
  }

  Future<void> _playYoutubeTrack(MusicTrack track) async {
    final videoId = _extractYoutubeVideoId(track.audioUrl);
    if (videoId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat memutar musik YouTube ini.')),
        );
      }
      return;
    }

    await _playerManager.stopTrack();

    if (kIsWeb) {
      final success = await launchUrlString(track.audioUrl, webOnlyWindowName: '_blank');
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membuka YouTube.')),
        );
      }
      return;
    }

    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => YouTubePlayerPopup(
        track: track,
        videoId: videoId,
      ),
    );
  }

  String _youtubeThumbnailUrl(String url) {
    final videoId = _extractYoutubeVideoId(url);
    return videoId != null ? 'https://img.youtube.com/vi/$videoId/hqdefault.jpg' : '';
  }

  Future<void> _handleTrackTap(MusicTrack track) async {
    if (_isYouTubeTrack(track)) {
      await _playYoutubeTrack(track);
      return;
    }
    await _playTrack(track);
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
                      if (_playerManager.currentTrack != null) _buildBottomPlayerLight(selectedMood),
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
    final isCurrent = _playerManager.currentTrack?.audioUrl == track.audioUrl;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => _handleTrackTap(track),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      _isYouTubeTrack(track) ? _youtubeThumbnailUrl(track.audioUrl) : track.thumbnailUrl,
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
                      if (_isYouTubeTrack(track))
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('YouTube', style: GoogleFonts.poppins(fontSize: 10, color: Colors.red, fontWeight: FontWeight.w700)),
                        ),
                      if (_isYouTubeTrack(track)) const SizedBox(width: 6),
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
    final currentTrack = _playerManager.currentTrack;
    if (currentTrack == null || _isYouTubeTrack(currentTrack)) return const SizedBox.shrink();
    
    final currentPosition = _playerManager.currentPosition;
    final totalDuration = _playerManager.totalDuration;
    final isPlaying = _playerManager.isPlaying;
    
    final progress = totalDuration.inMilliseconds > 0 
        ? currentPosition.inMilliseconds / totalDuration.inMilliseconds 
        : 0.0;

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
            LinearProgressIndicator(value: progress.clamp(0.0, 1.0), color: selectedMood.color, backgroundColor: Colors.grey.shade200, minHeight: 4),
            const SizedBox(height: 8),
            Row(
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(currentTrack.thumbnailUrl, width: 48, height: 48, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(width: 48, height: 48, color: Colors.grey.shade200))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(currentTrack.title, style: GoogleFonts.outfit(fontWeight: FontWeight.w700)), Text(currentTrack.artist, style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54))])),
                IconButton(onPressed: _togglePlayPause, icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill, color: selectedMood.color, size: 36)),
                IconButton(
                  onPressed: () async {
                    await _playerManager.stopTrack();
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

class YouTubePlayerPopup extends StatefulWidget {
  final MusicTrack track;
  final String videoId;

  const YouTubePlayerPopup({super.key, required this.track, required this.videoId});

  @override
  State<YouTubePlayerPopup> createState() => _YouTubePlayerPopupState();
}

class _YouTubePlayerPopupState extends State<YouTubePlayerPopup> {
  late yt.YoutubePlayerController _controller;
  bool _hasHandledError = false;

  @override
  void initState() {
    super.initState();
    _controller = yt.YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const yt.YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        controlsVisibleAtStart: true,
        forceHD: false,
      ),
    )..addListener(_youtubeListener);
  }

  @override
  void dispose() {
    _controller.removeListener(_youtubeListener);
    _controller.dispose();
    super.dispose();
  }

  void _youtubeListener() {
    final value = _controller.value;
    if (!value.hasError || _hasHandledError) return;

    _hasHandledError = true;
    final errorMessage = (value.errorCode == 150 || value.errorCode == 101)
        ? 'Video ini dibatasi oleh pemilik. Membuka YouTube...'
        : 'Terjadi kesalahan pemutaran YouTube. Membuka YouTube...';

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      _openYoutubeExternally();
    }
  }

  Future<void> _openYoutubeExternally() async {
    final success = await launchUrlString(
      widget.track.audioUrl,
      mode: LaunchMode.externalApplication,
    );
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuka YouTube.')),
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return yt.YoutubePlayerBuilder(
      player: yt.YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: widget.track.source.contains('YouTube') ? Colors.red : Theme.of(context).primaryColor,
      ),
      builder: (context, player) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: widget.track.source.contains('YouTube') ? Colors.red : Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.track.title,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(child: player),
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.track.title, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 8),
                            Text(widget.track.artist, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54)),
                            const SizedBox(height: 16),
                            Text('Memutar dari YouTube', style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
