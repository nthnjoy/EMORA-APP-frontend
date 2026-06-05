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
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false, // Kita atur manual menggunakan padding viewInsets
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
                    decoration: const BoxDecoration(
                      color: Color(0xFFEDF3ED),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                                color: Colors.grey.shade300,
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
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 12),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 50),
                          height: _textFieldHeight,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAFBFA),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300, width: 1.0),
                          ),
                          child: TextField(
                            controller: _storyController,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                            decoration: InputDecoration(
                              hintText: 'Ceritakan apa yang kamu rasakan saat ini',
                              hintStyle: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFFAAAFA8), fontWeight: FontWeight.w400),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Bottom Buttons
                        Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            width: 130,
                            height: 42,
                            child: ElevatedButton(
                              onPressed: _isSending ? null : _submitStory,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF008000),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                elevation: 0,
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