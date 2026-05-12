import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/laravel_session_service.dart';
import '../services/user_service.dart';
import '../utils/gender_dialog.dart';
import 'login_page.dart';
import 'daily_boost_page.dart';
import 'mood_calender_page.dart';
import '../utils/theme_colors.dart';
import '../services/theme_manager.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoading = false;
  bool isLoggingOut = false;
  String? errorMessage;
  // Removed local user variable to avoid stale data
  // Map<String, dynamic>? user;
  int totalPoints = 0;

  @override
  void initState() {
    super.initState();
    // user = LaravelSessionService.user; // Removed local assignment
    _loadPoints();
    refreshProfile();
  }

  Future<void> _loadPoints() async {
    final sessionUser = LaravelSessionService.user;
    final sessionPoints = sessionUser != null ? (sessionUser['point'] ?? 0) : 0;

    setState(() {
      totalPoints = sessionPoints is int
          ? sessionPoints
          : int.tryParse(sessionPoints.toString()) ?? 0;
    });
  }

  Future<void> refreshProfile() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final result = await UserService.fetchCurrentUser();
    if (!mounted) return;

    if (result['success'] == true) {
      setState(
        () {},
      ); // Just refresh the UI, build() will use the latest from LaravelSessionService
      await _loadPoints();
    } else {
      setState(() {
        errorMessage = (result['message'] ?? 'Gagal memuat profil').toString();
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> logout() async {
    setState(() => isLoggingOut = true);

    await UserService.logout();
    LaravelSessionService.clear();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  void _showThemeModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final activeThemeId = LaravelSessionService.activeThemeId;
            final purchasedThemes = LaravelSessionService.purchasedThemeIds;
            final currentPoints = totalPoints;

            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Pilih Tema Aplikasi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Poin kamu: $currentPoints',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            childAspectRatio: 1.2,
                          ),
                      itemCount: ThemeColors.allThemes.length,
                      itemBuilder: (context, index) {
                        final theme = ThemeColors.allThemes[index];
                        final isOwned = purchasedThemes.contains(theme.id);
                        final isActive = activeThemeId == theme.id;

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isActive
                                  ? theme.color
                                  : Colors.grey.shade200,
                              width: isActive ? 3 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.color.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: theme.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                theme.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (!isOwned)
                                Text(
                                  '${theme.price} Poin',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 28,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isActive
                                        ? Colors.grey
                                        : (isOwned
                                              ? theme.color
                                              : Colors.orange),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: isActive
                                      ? null
                                      : () async {
                                          if (isOwned) {
                                            final res =
                                                await UserService.setActiveTheme(
                                                  theme.id,
                                                );
                                            if (res['success']) {
                                              ThemeManager().updateTheme(
                                                theme.id,
                                              );
                                              setModalState(() {});
                                              setState(() {});
                                            } else {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(res['message']),
                                                ),
                                              );
                                            }
                                          } else {
                                            if (currentPoints < theme.price) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Poin tidak cukup!',
                                                  ),
                                                ),
                                              );
                                              return;
                                            }

                                            final res =
                                                await UserService.buyTheme(
                                                  theme.id,
                                                  theme.price,
                                                );
                                            if (res['success']) {
                                              ThemeManager().updateTheme(
                                                theme.id,
                                              );
                                              await refreshProfile();
                                              setModalState(() {});
                                              setState(() {});
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Berhasil membeli tema!',
                                                  ),
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(res['message']),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                  child: Text(
                                    isActive
                                        ? 'Aktif'
                                        : (isOwned ? 'Pakai' : 'Beli'),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPoinModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 30,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3C641),
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            right: -10,
                            top: -5,
                            child: Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF6A039),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black87,
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            bottom: 0,
                            child: Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF6A039),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black87,
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.star_border,
                                color: Colors.black87,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Total Poin',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$totalPoints',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              Center(
                child: SizedBox(
                  width: 130,
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Selesai',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 45.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 90,
              child: Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.black87),
              ),
            ),
            const Text(
              ':',
              style: TextStyle(fontSize: 11, color: Colors.black87),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontSize: 11, color: Colors.black87),
              ),
            ),
            if (onTap != null)
              const Icon(Icons.edit, size: 12, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(IconData icon, String title, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black54, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, 3),
            blurRadius: 4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap ?? () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 20, color: Colors.black87),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName = LaravelSessionService.displayName;
    final currentUser = LaravelSessionService.user;
    final username = currentUser?['username']?.toString() ?? '-';
    final nim = currentUser?['nim']?.toString() ?? '-';
    final email = currentUser?['email']?.toString() ?? '-';
    final prodi = currentUser?['prodi']?.toString() ?? '-';
    final angkatan = currentUser?['angkatan']?.toString() ?? '-';
    final asrama = currentUser?['asrama']?.toString() ?? '-';
    final gender = currentUser?['jenis_kelamin']?.toString() ?? '-';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: refreshProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.topCenter,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage('assets/image/dashbord.png'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.elliptical(
                          MediaQuery.of(context).size.width,
                          100,
                        ),
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.2),
                            Colors.white.withOpacity(0.4),
                          ],
                        ),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.elliptical(
                            MediaQuery.of(context).size.width,
                            100,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 130,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(
                        context,
                      ).primaryColor.withOpacity(0.2),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/image/boy.png',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.orange,
                              ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              Text(
                displayName.isNotEmpty ? displayName : 'Pengguna',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.blue,
                  decorationThickness: 2,
                ),
              ),
              const SizedBox(height: 20),
              _buildInfoRow('Username', username),
              _buildInfoRow('NIM', nim),
              _buildInfoRow('Program Studi', prodi),
              _buildInfoRow('Email', email),
              _buildInfoRow('Angkatan', angkatan),
              _buildInfoRow('Asrama', asrama),
              _buildInfoRow(
                'Jenis Kelamin',
                gender,
                onTap: () async {
                  await GenderDialog.show(context);
                  refreshProfile();
                },
              ),
              const SizedBox(height: 30),
              _buildMenuButton(Icons.brush, 'Tema', onTap: _showThemeModal),
              _buildMenuButton(Icons.stars, 'Poin', onTap: _showPoinModal),
              _buildMenuButton(Icons.error_outline, 'Panduan'),
              _buildMenuButton(
                Icons.history,
                'Riwayat',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MoodCalendarPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 15),
              _buildMenuButton(
                Icons.logout,
                isLoggingOut ? 'Keluar...' : 'Keluar Akun',
                onTap: isLoggingOut ? null : logout,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
