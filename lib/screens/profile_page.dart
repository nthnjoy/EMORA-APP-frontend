import 'package:flutter/material.dart';
import '../services/laravel_session_service.dart';
import '../services/user_service.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoading = false;
  bool isLoggingOut = false;
  String? errorMessage;
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    user = LaravelSessionService.user;
    refreshProfile();
  }

  Future<void> refreshProfile() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final result = await UserService.fetchCurrentUser();
    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        user = LaravelSessionService.user;
      });
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

  @override
  Widget build(BuildContext context) {
    final displayName = LaravelSessionService.displayName;
    final username = user?['username']?.toString() ?? '-';
    final nim = user?['nim']?.toString() ?? '-';
    final tokenSource = LaravelSessionService.tokenSource ?? '-';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text('Username: $username'),
            const SizedBox(height: 4),
            Text('NIM: $nim'),
            const SizedBox(height: 4),
            Text('Token Source: $tokenSource'),
            const SizedBox(height: 20),
            if (errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (errorMessage != null) const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : refreshProfile,
                icon: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.refresh),
                label: Text(isLoading ? 'Memuat...' : 'Refresh profil'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isLoggingOut ? null : logout,
                icon: isLoggingOut
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.logout),
                label: Text(isLoggingOut ? 'Logout...' : 'Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}