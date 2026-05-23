import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/wellness/breathing_view.dart';
import '../screens/wellness/vent_view.dart';
import '../screens/wellness/gratitude_view.dart';
import '../screens/wellness/zen_timer_view.dart';
import '../screens/wellness/reflection_view.dart';
import '../screens/wellness/audio_relaxation_view.dart';
import '../screens/wellness/happiness_cards_view.dart';
import '../screens/wellness/activity_tools_set1.dart';
import '../screens/wellness/activity_tools_set2.dart';
import '../screens/wellness/activity_tools_set3.dart';
import '../screens/wellness/drawing_view.dart';
import '../screens/wellness/bubble_pop_view.dart';
import '../screens/wellness/affirmation_swiper_view.dart';
import '../screens/wellness/physical_tools.dart';
import '../screens/wellness/creative_tools.dart';
import '../screens/wellness/focus_tools.dart';
import '../screens/wellness/tech_wellness_tools.dart';

enum ActivityCategory { calm, energy, express, reflect, growth, social, creative }

class WellnessActivity {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final ActivityCategory category;
  final Widget Function(BuildContext) targetView;

  WellnessActivity({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.category,
    required this.targetView,
  });
}

class ActivityService {
  static final List<WellnessActivity> _pool = [
    WellnessActivity(
        title: 'Debug Pikiran',
        subtitle: 'Hapus backlog emosi yang menumpuk.',
        icon: Icons.bug_report_rounded,
        color: Colors.redAccent,
        category: ActivityCategory.express,
        targetView: (_) => const BubblePopView()),
    WellnessActivity(
        title: 'System Reset',
        subtitle: 'Reboot sistem saraf dengan napas 4-7-8.',
        icon: Icons.restart_alt_rounded,
        color: Colors.cyanAccent,
        category: ActivityCategory.express,
        targetView: (_) => const BreathingView(pattern: BreathingPattern.relax478)),
    WellnessActivity(
        title: 'Buffer Clear',
        subtitle: 'Keluarkan beban memori jangka pendek.',
        icon: Icons.cleaning_services_rounded,
        color: Colors.amberAccent,
        category: ActivityCategory.express,
        targetView: (_) => const SlicerStressView()),
    WellnessActivity(
        title: 'Logic Knot',
        subtitle: 'Urai benang kusut dalam pikiranmu.',
        icon: Icons.hub_rounded,
        color: Colors.indigoAccent,
        category: ActivityCategory.growth,
        targetView: (_) => const LogicKnotView()),
    WellnessActivity(
        title: 'Binary Rain',
        subtitle: 'Fokus pada aliran data ketenangan.',
        icon: Icons.data_array_rounded,
        color: Colors.greenAccent,
        category: ActivityCategory.calm,
        targetView: (_) => const BinaryRainView()),
    WellnessActivity(
        title: 'Galaxy Architect',
        subtitle: 'Bangun galaksi ketenanganmu sendiri.',
        icon: Icons.auto_awesome_rounded,
        color: Colors.purpleAccent,
        category: ActivityCategory.creative,
        targetView: (_) => const GalaxyArchitectView()),
    WellnessActivity(
        title: 'Popcorn Stres',
        subtitle: 'Letuskan biji jagung emosimu.',
        icon: Icons.trip_origin,
        color: Colors.orange,
        category: ActivityCategory.express,
        targetView: (_) => const PopcornView()),
    WellnessActivity(
        title: 'Pasir Ajaib',
        subtitle: 'Bermain dengan pasir partikel emosi.',
        icon: Icons.grain,
        color: Colors.brown,
        category: ActivityCategory.creative,
        targetView: (_) => const MagicSandView()),
    WellnessActivity(
        title: 'Code Zen',
        subtitle: 'Lukis algoritma damai di kanvas.',
        icon: Icons.brush_rounded,
        color: Colors.purpleAccent,
        category: ActivityCategory.creative,
        targetView: (_) => const DrawingView()),
  ];

  static Future<void> saveLastMood(String mood, String feeling) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_mood', mood);
    await prefs.setString('last_feeling', feeling);
  }

  static Future<Map<String, String?>> getLastMood() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'mood': prefs.getString('last_mood'),
      'feeling': prefs.getString('last_feeling'),
    };
  }

  static List<WellnessActivity> getActivities() => _pool;

  static List<WellnessActivity> getRecommendations(String? mood, String? feeling) {
    if (mood == null) return _pool.take(5).toList();

    List<ActivityCategory> targets = [];
    
    switch (mood.toLowerCase()) {
      case 'marah':
        targets = [ActivityCategory.calm, ActivityCategory.express, ActivityCategory.calm, ActivityCategory.express, ActivityCategory.calm];
        break;
      case 'sedih':
        targets = [ActivityCategory.reflect, ActivityCategory.express, ActivityCategory.growth, ActivityCategory.reflect, ActivityCategory.calm];
        break;
      case 'takut':
        targets = [ActivityCategory.calm, ActivityCategory.calm, ActivityCategory.growth, ActivityCategory.calm, ActivityCategory.reflect];
        break;
      case 'senang':
      case 'antusias':
        targets = [ActivityCategory.reflect, ActivityCategory.energy, ActivityCategory.growth, ActivityCategory.reflect, ActivityCategory.social];
        // Note: I'll use reflect/energy for energy if social is not defined
        break;
      case 'netral':
      case 'biasa':
        targets = [ActivityCategory.reflect, ActivityCategory.growth, ActivityCategory.energy, ActivityCategory.reflect, ActivityCategory.calm];
        break;
      case 'terkejut':
        targets = [ActivityCategory.calm, ActivityCategory.reflect, ActivityCategory.calm, ActivityCategory.reflect, ActivityCategory.growth];
        break;
      default:
        targets = [ActivityCategory.calm, ActivityCategory.reflect, ActivityCategory.express, ActivityCategory.growth, ActivityCategory.energy];
    }

    List<WellnessActivity> results = [];
    Set<String> usedTitles = {};

    for (var cat in targets) {
      final possible = _pool.where((a) => a.category == cat || (cat == ActivityCategory.social && a.category == ActivityCategory.reflect)).toList();
      possible.shuffle();
      for (var act in possible) {
        if (!usedTitles.contains(act.title)) {
          results.add(act);
          usedTitles.add(act.title);
          break;
        }
      }
    }
    
    // Fill to 5 if needed
    if (results.length < 5) {
      final remaining = _pool.where((a) => !usedTitles.contains(a.title)).toList();
      remaining.shuffle();
      results.addAll(remaining.take(5 - results.length));
    }

    return results.take(5).toList();
  }
}
