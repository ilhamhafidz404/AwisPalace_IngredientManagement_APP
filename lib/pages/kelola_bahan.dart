import 'package:flutter/material.dart';
import '../features/menu/presentation/pages/menu_page.dart';
import 'profile_page.dart';

class KelolaBahanPage extends StatefulWidget {
  const KelolaBahanPage({super.key});

  @override
  State<KelolaBahanPage> createState() => _KelolaBahanPageState();
}

class _KelolaBahanPageState extends State<KelolaBahanPage> {
  final int _selectedIndex = 2;

  List<Map<String, dynamic>> bahanList = [
    {"nama": "Masako", "jumlah": 1},
    {"nama": "Royco", "jumlah": 1},
    {"nama": "Kecap Asin", "jumlah": 1},
  ];

  /// =================== EDIT BAHAN ===================
  void editItem(int index) {
    TextEditingController namaC = TextEditingController(
      text: bahanList[index]["nama"],
    );
    TextEditingController jumlahC = TextEditingController(
      text: bahanList[index]["jumlah"].toString(),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Edit Bahan"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaC,
              decoration: const InputDecoration(labelText: "Nama Bahan"),
            ),
            TextField(
              controller: jumlahC,
              decoration: const InputDecoration(labelText: "Jumlah (pcs)"),
              keyboardType: TextInputType.number,
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
                bahanList[index]["nama"] = namaC.text;
                bahanList[index]["jumlah"] = int.tryParse(jumlahC.text) ?? 0;
              });

              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  /// =================== HAPUS ===================
  void deleteItem(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Hapus Bahan"),
        content: Text("Yakin ingin menghapus *${bahanList[index]["nama"]}*?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() => bahanList.removeAt(index));
              Navigator.pop(context);
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  /// =================== NAVIGATION ===================
  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MenuPage()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfilePage()),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Fitur ini belum tersedia.")),
        );
    }
  }

  /// ===================== UI ======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff00C3FF),
        title: const Text(
          "Kelola Bahan",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: bahanList.length,
        itemBuilder: (context, index) {
          final item = bahanList[index];

          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),

              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey.shade300,
                  child: const Icon(
                    Icons.inventory,
                    size: 30,
                    color: Colors.black54,
                  ),
                ),
              ),

              title: Text(
                item["nama"],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text("Tersedia: ${item['jumlah']} pcs"),

              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => editItem(index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteItem(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff00C3FF),
        child: const Icon(Icons.add),
        onPressed: () {},
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Hitung'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Kelola'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Menu'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
