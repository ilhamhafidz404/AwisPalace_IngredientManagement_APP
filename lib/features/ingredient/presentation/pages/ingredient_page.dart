import 'package:flutter/material.dart';
import 'package:ingredient_management_app/widgets/custom_bottom_nav.dart';
import 'package:ingredient_management_app/widgets/custom_bottom_nav_handler.dart';

class IngredientPage extends StatefulWidget {
  const IngredientPage({super.key});

  @override
  State<IngredientPage> createState() => _IngredientPageState();
}

class _IngredientPageState extends State<IngredientPage> {
  final int currentIndex = 2;

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

  /// ===================== UI ======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {},
      ),

      bottomNavigationBar: CustomBottomNav(
        selectedIndex: currentIndex,
        onItemTapped: (i) =>
            CustomBottomNavHandler.onItemTapped(context, currentIndex, i),
      ),
    );
  }
}
