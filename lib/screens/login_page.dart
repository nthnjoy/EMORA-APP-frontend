import 'package:flutter/material.dart';
import 'package:emolens_app/screens/main_navigation_page.dart';
import 'package:emolens_app/services/laravel_auth_service.dart';
import 'package:emolens_app/services/laravel_session_service.dart';
import 'package:emolens_app/services/user_service.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    // VALIDASI INPUT
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                username.isEmpty && password.isEmpty
                    ? "Username dan Password wajib diisi"
                    : username.isEmpty
                        ? "Username wajib diisi"
                        : "Password wajib diisi",
                style: GoogleFonts.poppins(),
              ),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

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
          _showErrorSnackBar("Login CIS berhasil, tetapi sinkronisasi database gagal.");
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
        _showErrorSnackBar(result['message'] ?? "Username atau password salah");
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint("Login error: $e");
      
      String errorMsg = "Terjadi kesalahan koneksi. Pastikan internet Anda aktif.";
      if (e.toString().contains('TimeoutException')) {
        errorMsg = "Koneksi ke server timeout. Silakan coba lagi.";
      } else if (e.toString().contains('SocketException')) {
        errorMsg = "Gagal terhubung ke server. Cek koneksi internet Anda.";
      }
      
      _showErrorSnackBar(errorMsg);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
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
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/image/dashbord.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Overlay for readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
          // Main Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Title
                  Text(
                    'Emolens',
                    style: GoogleFonts.poppins(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pantau kesejahteraan mentalmu setiap hari',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Login Card
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Masuk',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gunakan akun CIS Anda',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Username Field
                        TextField(
                          controller: usernameController,
                          style: GoogleFonts.poppins(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: "Username CIS",
                            hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade500),
                            prefixIcon: const Icon(Icons.person_outline, color: const Color(0xFF4A6841)),
                            filled: true,
                            fillColor: const Color(0xFFF1F4EE), // Matching the light green theme
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          style: GoogleFonts.poppins(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: "Password",
                            hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade500),
                            prefixIcon: const Icon(Icons.lock_outline, color: const Color(0xFF4A6841)),
                            filled: true,
                            fillColor: const Color(0xFFF1F4EE),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A6841), // Deep sage green
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                              shadowColor: const Color(0xFF4A6841).withValues(alpha: 0.4),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    "Sign In",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}