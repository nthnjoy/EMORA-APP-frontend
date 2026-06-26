import 'package:flutter/material.dart';
import '../services/system_service.dart';

class CounselingPage extends StatefulWidget {
  const CounselingPage({super.key});

  @override
  State<CounselingPage> createState() => _CounselingPageState();
}

class _CounselingPageState extends State<CounselingPage> {
  bool isLoading = true;
  Map<String, dynamic>? pingResult;
  Map<String, dynamic>? dbResult;

  @override
  void initState() {
    super.initState();
    checkHealth();
  }

  Future<void> checkHealth() async {
    setState(() => isLoading = true);

    final ping = await SystemService.ping();
    final db = await SystemService.testDb();

    if (!mounted) return;
    setState(() {
      pingResult = ping;
      dbResult = db;
      isLoading = false;
    });
  }

  Widget _statusCard({
    required String title,
    required Map<String, dynamic>? result,
  }) {
    final success = result?['success'] == true;
    final message = (result?['message'] ?? '-').toString();
    final statusCode = (result?['status_code'] ?? '-').toString();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: success ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Status: ${success ? "OK" : "ERROR"}'),
          Text('HTTP: $statusCode'),
          const SizedBox(height: 4),
          Text(message),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Konseling & Status Sistem"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (isLoading) const LinearProgressIndicator(),
            const SizedBox(height: 12),
            _statusCard(
              title: 'Backend API',
              result: pingResult,
            ),
            _statusCard(
              title: 'MongoDB Connection',
              result: dbResult,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : checkHealth,
                icon: const Icon(Icons.refresh),
                label: const Text('Cek ulang status'),
              ),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Catatan: modul konseling chat belum memiliki endpoint backend khusus.',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}