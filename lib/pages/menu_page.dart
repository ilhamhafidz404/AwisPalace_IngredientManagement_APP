import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final int _selectedIndex = 3;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 1:
        Navigator.pushReplacementNamed(context, '/hitung');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/kelola');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/menu');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  List<Map<String, String>> menuItems = [
    {
      'nama': 'Nasi Goreng',
      'stok': '3 porsi',
      'gambar': 'assets/img/nasigoreng.png',
    },
    {
      'nama': 'Mie Goreng',
      'stok': '2 porsi',
      'gambar': 'assets/img/nasigoreng.png',
    },
    {
      'nama': 'Sate Ayam',
      'stok': '4 porsi',
      'gambar': 'assets/img/nasigoreng.png',
    },
  ];

  /// ===================== FUNGSI EDIT ==========================

  void editMenu(int index) {
    TextEditingController namaC = TextEditingController(
      text: menuItems[index]['nama'],
    );
    TextEditingController stokC = TextEditingController(
      text: menuItems[index]['stok'],
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Edit Menu"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaC,
              decoration: const InputDecoration(labelText: "Nama menu"),
            ),
            TextField(
              controller: stokC,
              decoration: const InputDecoration(labelText: "Stok"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                menuItems[index]['nama'] = namaC.text;
                menuItems[index]['stok'] = stokC.text;
              });
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  /// ===================== FUNGSI HAPUS ==========================

  void deleteMenu(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Hapus Menu?"),
        content: Text("Yakin ingin menghapus *${menuItems[index]['nama']}*?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() => menuItems.removeAt(index));
              Navigator.pop(context);
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  /// ========================== UI ==============================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff00C3FF),
        title: const Text("Kelola Menu", style: TextStyle(color: Colors.white)),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(10),

              leading: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  item['gambar']!,
                  width: 55,
                  height: 55,
                  fit: BoxFit.cover,
                ),
              ),

              title: Text(
                item['nama']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text("Tersedia: ${item['stok']}"),

              /// =================== BUTTON EDIT + HAPUS DI KANAN ===================
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => editMenu(index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteMenu(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff00C3FF),
        onPressed: () {},
        child: const Icon(Icons.add),
      ),

      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
