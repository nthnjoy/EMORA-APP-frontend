import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MoodPage extends StatefulWidget {
  final String initialMood;
  final String initialFeeling;

  const MoodPage({super.key, required this.initialMood, required this.initialFeeling});

  @override
  State<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends State<MoodPage> {
  late String selectedMood;
  final TextEditingController noteController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  bool isLoading = false;

  final Map<String, int> moodCodeMap = {
    'Happy': 1,
    'Sad': 2,
    'Angry': 3,
    'Fearful': 4,
    'Neutral': 5,
    'Surprised': 6,
    'senang': 1,
    'marah': 2,
    'sedih': 3,
    'takut': 4,
    'biasa': 5,
    'kaget': 6,
    'jijik': 7,
    'lega': 8,
    'frustrasi': 9,
    'penasaran': 10,
  };

  @override
  void initState() {
    super.initState();
    selectedMood = widget.initialMood;
  }

  Future<void> saveMood() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      setState(() {
        isLoading = true;
      });

      int moodCode = moodCodeMap[selectedMood] ?? 0;

      await FirebaseFirestore.instance.collection('moods').add({
        'userId': user.uid,
        'email': user.email,
        'mood_label': selectedMood,
        'perasaan': widget.initialFeeling,
        'emosi_kode': moodCode,
        'title': titleController.text,
        'note': noteController.text,
        'createdAt': Timestamp.now(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mood berhasil disimpan ✅")),
      );

      titleController.clear();
      noteController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan mood: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    noteController.dispose();
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.local_fire_department, color: Colors.purple),
            const SizedBox(width: 8),
            const Text(
              "IT DEL EMOLENS",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purpleAccent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "5 Streak",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {},
            )
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF9CC7F5), Color(0xFFDCE8F4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Mood: ${selectedMood.toUpperCase()}",
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Perasaan: ${widget.initialFeeling.toUpperCase()}",
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            const Text(
              "Tambahkan catatan untuk menjelaskan apa yang Anda rasakan hari ini.",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: "Judul ceritamu..",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: noteController,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  hintText: "Tuliskan perasaanmu...",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("KEMBALI"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : saveMood,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("KIRIM"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}