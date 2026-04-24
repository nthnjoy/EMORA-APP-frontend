import 'package:flutter/material.dart';
import '../services/story_service.dart';
class StoryPage extends StatefulWidget {
  const StoryPage({super.key});

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  final TextEditingController _storyController = TextEditingController();
  bool _isSending = false;

  Future<void> _submitStory() async {
    if (_storyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tulis cerita atau perasaanmu terlebih dahulu.'),
        ),
      );
      return;
    }

    setState(() => _isSending = true);
    
    final result = await StoryService.createStory(
      content: _storyController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _isSending = false);
    
    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cerita kamu berhasil dikirim.')),
      );
      _storyController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Gagal mengirim cerita.')),
      );
    }
  }

  @override
  void dispose() {
    _storyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pojok Cerita'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ceritakan tentang perasaanmu...',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tulis cerita singkat tentang suasana hati, pengalaman, atau hal yang ingin kamu keluarkan.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TextField(
                controller: _storyController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: 'Tuliskan apa yang kamu rasakan saat ini...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSending ? null : _submitStory,
                child: _isSending
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Kirim'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
