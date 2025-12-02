import 'package:flutter/material.dart';

class DetailMenuPage extends StatelessWidget {
  final String nama;
  final String gambar;

  const DetailMenuPage({super.key, required this.nama, required this.gambar});

  @override
  Widget build(BuildContext context) {
    final bahan = [
      ["Nasi", "1 Piring"],
      ["Telur", "1 Butir"],
      ["Minyak Goreng", "2 Sdm"],
      ["Bawang Putih", "2 Siung"],
      ["Bawang Merah", "2 Siung"],
      ["Cabai", "3 Butir"],
      ["Kecap Manis", "2 Sdm"],
      ["Garam", "1/2 Sdt"],
      ["Royko", "1/2 Sdt"],
      ["Lada", "1/4 Sdt"],
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BCEE),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Detail Menu", style: TextStyle(color: Colors.white)),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                gambar,
                width: 250,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              nama,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // LIST BAHAN
            Column(
              children: bahan.map((item) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("• ${item[0]}", style: const TextStyle(fontSize: 16)),
                    Text(item[1], style: const TextStyle(fontSize: 16)),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
