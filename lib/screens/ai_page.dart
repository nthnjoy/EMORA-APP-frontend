import 'package:flutter/material.dart';

class AiPage extends StatelessWidget {
  const AiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.smart_toy, size: 64, color: Colors.deepPurple),
              SizedBox(height: 24),
              Text(
                'Fitur AI akan segera hadir.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Untuk sekarang halaman ini hanya tempat penampungan sementara sampai AI siap.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
