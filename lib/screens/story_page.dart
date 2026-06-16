import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/story_service.dart';
import '../services/laravel_session_service.dart';
import '../utils/ai_dialog.dart';
import '../widgets/app_avatar.dart';

class StoryPage extends StatefulWidget {
  const StoryPage({super.key});

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  final TextEditingController _storyController = TextEditingController();
  bool _isSending = false;
  double _textFieldHeight = 180.0;

  Future<void> _submitStory() async {
    final content = _storyController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tulis cerita atau perasaanmu terlebih dahulu.')),
      );
      return;
    }

    setState(() => _isSending = true);
    
    final result = await StoryService.createStory(content: content);

    if (!mounted) return;
    setState(() => _isSending = false);
    
    if (result['success'] == true) {
      final feedback = result['ai_feedback'] ?? 'Cerita kamu sangat berharga. Terima kasih sudah berbagi!';
      
      await AiDialog.show(context, feedback);
      
      final int aiLevel = result['ai_level'] is int 
          ? result['ai_level'] 
          : int.tryParse(result['ai_level']?.toString() ?? '0') ?? 0;
          
      // Force trigger untuk akun testing Whisnu
      final String? userNim = LaravelSessionService.user?['nim']?.toString();
      final String? username = LaravelSessionService.user?['username']?.toString();
      final bool isTestingUser = userNim == '11423045' || username == 'whisnu';
          
      if (aiLevel == 3 || isTestingUser) {
        if (!mounted) return;
        await AiDialog.showWarning(
          context,
          'Sepertinya kamu tidak baik-baik saja. Coba lakukan konseling untuk membantu meredakan perasaanmu.',
        );
      }
      
      if (!mounted) return;
      _storyController.clear();
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Gagal mengirim cerita.')),
      );
    }
  }

  Widget _buildStoryAvatar() {
    final gender = LaravelSessionService.user?['jenis_kelamin']?.toString();
    return AppAvatar(gender: gender, radius: 20);
  }

  @override
  void dispose() {
    _storyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayName = LaravelSessionService.user?['name'] ?? 'Pengguna';
    final primaryColor = Theme.of(context).primaryColor;

    // Warna background sheet mengikuti tema — dibuat lebih terang dari primaryColor
    final sheetBg = Color.lerp(primaryColor.withOpacity(0.08), Colors.white, 0.82) ?? const Color(0xFFEDF3ED);
    final sendBtnColor = primaryColor;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // Background gelap yang bisa di-tap untuk tutup
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(color: Colors.black54),
            ),
            // Konten form
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: sheetBg,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onVerticalDragUpdate: (details) {
                            setState(() {
                              _textFieldHeight -= details.delta.dy;
                              if (_textFieldHeight < 100) _textFieldHeight = 100;
                              final maxHeight = MediaQuery.of(context).size.height * 0.6;
                              if (_textFieldHeight > maxHeight) _textFieldHeight = maxHeight;
                            });
                          },
                          onVerticalDragEnd: (details) {
                            if (details.primaryVelocity != null && details.primaryVelocity! > 800) {
                              Navigator.of(context).pop();
                            }
                          },
                          child: Container(
                            color: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 50),
                            child: Container(
                              width: 48,
                              height: 5,
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildStoryAvatar(),
                            const SizedBox(width: 12),
                            Text(
                              displayName,
                              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Ceritakan tentang perasaanmu..',
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ),
                        const SizedBox(height: 12),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 50),
                          height: _textFieldHeight,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAFBFA),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: primaryColor.withOpacity(0.18), width: 1.2),
                          ),
                          child: TextField(
                            controller: _storyController,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                            decoration: InputDecoration(
                              hintText: 'Ceritakan apa yang kamu rasakan saat ini',
                              hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.black38, fontWeight: FontWeight.w400),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Tombol Kirim
                        Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            width: 130,
                            height: 42,
                            child: ElevatedButton(
                              onPressed: _isSending ? null : _submitStory,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: sendBtnColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                elevation: 3,
                                shadowColor: sendBtnColor.withOpacity(0.4),
                              ),
                              child: _isSending
                                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : Text('Kirim', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}