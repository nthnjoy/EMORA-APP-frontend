import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'old_activity_page.dart';
import '../services/activity_service.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  String _selectedCategory = 'DEBUG';
  List<WellnessActivity> _allActivities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    setState(() => _isLoading = true);
    final acts = ActivityService.getActivities();
    setState(() {
      _allActivities = acts;
      _isLoading = false;
    });
  }

  List<WellnessActivity> get _filteredActivities {
    if (_selectedCategory == 'DEBUG') return _allActivities.where((a) => a.category == ActivityCategory.express).toList();
    if (_selectedCategory == 'LAB') return _allActivities.where((a) => a.category == ActivityCategory.calm || a.category == ActivityCategory.growth).toList();
    return _allActivities.where((a) => a.category == ActivityCategory.creative).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
        : CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(child: _buildCategorySelector()),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildQuestCard(context, _filteredActivities[index]),
                    childCount: _filteredActivities.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: const Color(0xFF0F172A),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('BIO-HACKER HUB', style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.history_rounded, color: Colors.white38, size: 20),
                          tooltip: 'Lihat Versi Klasik (V1)',
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OldActivityPage())),
                        ),
                        const Icon(Icons.shield_rounded, color: Colors.cyanAccent, size: 28),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('SYSTEM STATUS: OPTIMAL', style: GoogleFonts.orbitron(color: Colors.greenAccent, fontSize: 9, letterSpacing: 1)),
                const SizedBox(height: 8),
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.75,
                    child: Container(decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.cyanAccent, Colors.blueAccent]), borderRadius: BorderRadius.circular(10))),
                  ),
                ),
                const SizedBox(height: 8),
                Text('WELLNESS PERFORMANCE: 75%', style: GoogleFonts.orbitron(color: Colors.white60, fontSize: 8)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _catItem('DEBUG', Icons.bug_report_rounded),
          _catItem('LAB', Icons.science_rounded),
          _catItem('DORM', Icons.nightlight_rounded),
        ],
      ),
    );
  }

  Widget _catItem(String id, IconData icon) {
    bool isSel = _selectedCategory == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = id),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSel ? Colors.cyanAccent : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSel ? Colors.cyanAccent : Colors.white10),
              boxShadow: [if(isSel) BoxShadow(color: Colors.cyanAccent.withOpacity(0.2), blurRadius: 15)],
            ),
            child: Icon(icon, color: isSel ? Colors.black : Colors.white60),
          ),
          const SizedBox(height: 8),
          Text(id, style: GoogleFonts.orbitron(fontSize: 10, color: isSel ? Colors.cyanAccent : Colors.white24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildQuestCard(BuildContext context, WellnessActivity act) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => act.targetView(context))),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(color: act.color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
                child: Icon(act.icon, color: act.color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(act.title.toUpperCase(), style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(act.subtitle, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white54)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white24),
            ],
          ),
        ),
      ),
    );
  }
}



