import 'package:flutter/material.dart';

class FeelingPage extends StatefulWidget {
  final String selectedMood;

  const FeelingPage({
    super.key,
    required this.selectedMood,
  });

  @override
  State<FeelingPage> createState() => _FeelingPageState();
}

class _FeelingPageState extends State<FeelingPage> {
  String? selectedFeeling;

  final Map<String, List<String>> feelingMap = {
    'Senang': [
      'Aktif',
      'Antusias',
      'Bosan',
      'Jemu',
      'Bersemangat',
      'Malas',
      'Takut',
      'Marah',
      'Cemas',
      'Gugup',
      'Letih',
      'Santai',
      'Kalem',
      'Damai',
      'Gugup',
      'Enerjik',
      'Tenang',
    ],
    'Marah': [
      'Kesal',
      'Tersinggung',
      'Jengkel',
      'Emosi',
      'Geram',
      'Frustrasi',
      'Kecewa',
      'Tegang',
    ],
    'Sedih': [
      'Kecewa',
      'Murung',
      'Kesepian',
      'Hampa',
      'Menyesal',
      'Lelah',
      'Terpuruk',
      'Putus Asa',
    ],
    'Takut': [
      'Khawatir',
      'Panik',
      'Tidak Aman',
      'Tegang',
      'Curiga',
      'Gelisah',
      'Cemas',
      'Gugup',
    ],
    'Biasa': [
      'Netral',
      'Tenang',
      'Stabil',
      'Santai',
      'Kalem',
      'Fokus',
    ],
    'Terkejut': [
      'Kaget',
      'Bingung',
      'Takjub',
      'Heran',
      'Terpana',
      'Tercengang',
    ],
    'Jijik': [
      'Muak',
      'Tidak Suka',
      'Mual',
      'Terganggu',
      'Risih',
      'Enggan',
    ],
  };

  @override
  Widget build(BuildContext context) {
    final List<String> feelings =
        feelingMap[widget.selectedMood] ?? ['Tenang', 'Cemas', 'Fokus'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Perasaan'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bagaimana perasaanmu saat memilih ${widget.selectedMood}?',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Pilih satu atau lebih perasaan yang paling sesuai.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: feelings.asMap().entries.map((entry) {
                  final feeling = entry.value;
                  final isSelected = selectedFeeling == feeling;

                  return FilterChip(
                    label: Text(feeling),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedFeeling = selected ? feeling : null;
                      });
                    },
                    backgroundColor: Colors.grey.shade100,
                    selectedColor: Colors.blue.shade200,
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.blue : Colors.black87,
                    ),
                  );
                }).toList(),
              ),
              if (selectedFeeling != null) ...[
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, selectedFeeling);
                    },
                    child: Text(
                      'Lanjut: $selectedFeeling',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

