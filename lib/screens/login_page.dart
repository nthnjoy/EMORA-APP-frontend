import 'package:flutter/material.dart';
import 'package:emolens_app/screens/main_navigation_page.dart';
import 'package:emolens_app/services/laravel_auth_service.dart';
import 'package:emolens_app/services/laravel_session_service.dart';
import 'package:emolens_app/services/user_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  void login() async {
    setState(() => isLoading = true);

    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    // VALIDASI INPUT
    if (username.isEmpty || password.isEmpty) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username & Password wajib diisi")),
      );
      return;
    }

    try {
      final result = await LaravelAuthService.login(
        username: username,
        password: password,
      );
      if (!mounted) return;

      if (result['success'] == true) {
        LaravelSessionService.saveFromLoginResult(result);
        final tokenSource = (result['token_source'] ?? '')
            .toString()
            .trim()
            .toLowerCase();
        if (tokenSource != 'sanctum') {
          LaravelSessionService.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Login CIS berhasil, tetapi sinkronisasi MongoDB gagal. Cek koneksi database backend.",
              ),
            ),
          );
          setState(() => isLoading = false);
          return;
        }
        await UserService.fetchCurrentUser();
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? "Login gagal")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Terjadi kesalahan")));
    }

    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 80),
            const SizedBox(height: 20),

            // 🔥 USERNAME
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // 🔥 PASSWORD
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // 🔥 BUTTON LOGIN
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : login,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Login"),
              ),
            ),

            const SizedBox(height: 10),

            // TextButton untuk daftar dihapus karena tidak ada sistem daftar
          ],
        ),
      ),
    );
  }
}
