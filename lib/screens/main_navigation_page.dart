import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'self_care_page.dart';
import 'mood_calender_page.dart';
import 'profile_page.dart';
import '../services/laravel_session_service.dart';
import '../utils/gender_dialog.dart';
import '../services/counselor_notification_service.dart';
import '../widgets/mini_player_widget.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  static MainNavigationPageState? of(BuildContext context) =>
      context.findAncestorStateOfType<MainNavigationPageState>();

  @override
  State<MainNavigationPage> createState() => MainNavigationPageState();
}

class MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages = [
    const DashboardPage(),
    SelfCarePage(onBackToDashboard: () => switchTab(0)),
    MoodCalendarPage(onBackToDashboard: () => switchTab(0)),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkGender();
      CounselorNotificationService().startPolling();
    });
  }

  @override
  void dispose() {
    CounselorNotificationService().stopPolling();
    super.dispose();
  }

  Future<void> _checkGender() async {
    if (!LaravelSessionService.hasGender) {
      await GenderDialog.show(context);
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  void switchTab(int index) => _onItemTapped(index);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _selectedIndex != 0) {
          _onItemTapped(0);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: _pages,
              ),
            ),
            const MiniPlayerWidget(),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              backgroundColor: Colors.white,
              selectedItemColor: Theme.of(context).primaryColor,
              unselectedItemColor: Theme.of(context).primaryColor.withOpacity(0.4),
              showSelectedLabels: true,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              iconSize: 24,
              selectedFontSize: 10,
              unselectedFontSize: 10,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Dashboard"),
                BottomNavigationBarItem(icon: Icon(Icons.extension), label: "Self-Care"),
                BottomNavigationBarItem(icon: Icon(Icons.calendar_today_rounded), label: "History"),
                BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Profile"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
