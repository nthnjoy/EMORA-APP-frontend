import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/user_service.dart';
import '../services/theme_manager.dart';
import '../screens/main_navigation_page.dart';

class GenderDialog {
  static Future<void> show(BuildContext context, {bool isProfileEdit = false}) async {
    String? selectedGender;
    final titleText = isProfileEdit
        ? 'Mengubah Data Jenis Kelamin Anda?'
        : 'Halo, Selamat Datang!';
    final subtitleText = isProfileEdit
        ? 'Lakukan perubahan sesuai dengan data Jenis Kelamin anda!'
        : 'Untuk menyesuaikan kenyamanan Anda, bolehkah kami tahu jenis kelamin Anda?';

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_outline, color: Colors.blue, size: 32),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      titleText,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      subtitleText,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => selectedGender = "Laki-laki"),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: selectedGender == "Laki-laki" 
                                  ? Colors.blue.shade100 
                                  : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: selectedGender == "Laki-laki" 
                                    ? Colors.blue 
                                    : Colors.transparent,
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.male, color: Colors.blue),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Laki-laki",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      color: selectedGender == "Laki-laki" 
                                        ? Colors.blue.shade700 
                                        : Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => selectedGender = "Perempuan"),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: selectedGender == "Perempuan" 
                                  ? Colors.pink.shade100 
                                  : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: selectedGender == "Perempuan" 
                                    ? Colors.pink 
                                    : Colors.transparent,
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.female, color: Colors.pink),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Perempuan",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      color: selectedGender == "Perempuan" 
                                        ? Colors.pink.shade700 
                                        : Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: selectedGender == null 
                          ? null 
                          : () async {
                              final result = await UserService.updateGender(selectedGender!);
                              
                              // Check if dialog still mounted before proceeding
                              if (!context.mounted) return;
                              
                              if (result['success']) {
                                // Refresh user data dari server agar LaravelSessionService ter-update
                                await UserService.fetchCurrentUser();
                                
                                // Check mounted again after async operation
                                if (!context.mounted) return;
                                
                                // Sekarang theme manager bisa membaca gender yang sudah ter-update
                                ThemeManager().updateGenderAndTheme();
                                
                                // Close dialog
                                Navigator.of(context).pop();
                                
                                // Refresh seluruh aplikasi dengan full reload
                                if (context.mounted) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const MainNavigationPage(),
                                    ),
                                  );
                                }
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(result['message'])),
                                  );
                                }
                              }
                            },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        child: Text(
                          "Simpan",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
