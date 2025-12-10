import 'package:flutter/material.dart';
import 'package:ingredient_management_app/features/menu/presentation/widgets/delete_menu_dialog.dart';
import 'package:ingredient_management_app/features/menu/presentation/widgets/edit_menu_dialog.dart';
import 'package:ingredient_management_app/features/menu/presentation/widgets/menu_card.dart';
import 'package:ingredient_management_app/widgets/custom_bottom_nav_handler.dart';
import '../../../../widgets/custom_bottom_nav.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final int _selectedIndex = 1;

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
      builder: (_) => EditMenuDialog(
        namaC: namaC,
        stokC: stokC,
        onSave: () {
          setState(() {
            menuItems[index]['nama'] = namaC.text;
            menuItems[index]['stok'] = stokC.text;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  /// ===================== FUNGSI HAPUS ==========================

  void deleteMenu(int index) {
    showDialog(
      context: context,
      builder: (_) => DeleteMenuDialog(
        menuName: menuItems[index]['nama']!,
        onDelete: () {
          setState(() => menuItems.removeAt(index));
          Navigator.pop(context);
        },
      ),
    );
  }

  /// ========================== UI ==============================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xff00C3FF),
        title: const Text("Kelola Menu", style: TextStyle(color: Colors.white)),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];

          return MenuCard(
            nama: item['nama']!,
            stok: item['stok']!,
            gambar: item['gambar']!,
            onEdit: () => editMenu(index),
            onDelete: () => deleteMenu(index),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff00C3FF),
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white),
      ),

      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _selectedIndex,
        onItemTapped: (i) =>
            CustomBottomNavHandler.onItemTapped(context, _selectedIndex, i),
      ),
    );
  }
}
