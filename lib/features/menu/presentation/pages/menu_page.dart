import 'package:flutter/material.dart';
import 'package:ingredient_management_app/features/menu/data/models/menu_model.dart';
import 'package:ingredient_management_app/features/menu/data/services/menu_service.dart';
import 'package:ingredient_management_app/features/menu/presentation/pages/menu_form_page.dart';
import 'package:ingredient_management_app/features/menu/presentation/widgets/delete_menu_dialog.dart';
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
  late Future<List<MenuModel>> menusFuture;

  @override
  void initState() {
    super.initState();
    _loadMenus();
  }

  void _loadMenus() {
    menusFuture = MenuService.fetchMenus();
  }

  /// ===================== DELETE MENU ==========================
  void actionDeleteMenu(MenuModel menu) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DeleteMenuDialog(menuName: menu.name),
    );
    if (confirm != true) return;

    try {
      print("DELETE MENU START: ${menu.name}");

      await MenuService.deleteMenu(menu.id);

      print("DELETE MENU DONE");

      setState(() {
        _loadMenus();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Menu '${menu.name}' berhasil dihapus"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal menghapus menu: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
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

      body: FutureBuilder<List<MenuModel>>(
        future: menusFuture,
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Gagal memuat menu\n${snapshot.error}",
                textAlign: TextAlign.center,
              ),
            );
          }

          final menus = snapshot.data!;

          if (menus.isEmpty) {
            return const Center(child: Text("Menu masih kosong"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: menus.length,
            itemBuilder: (context, index) {
              final menu = menus[index];

              return MenuCard(
                nama: menu.name,
                stok: "Rp ${menu.price.toStringAsFixed(0)}",
                gambar: "http://alope.site:8080/uploads/${menu.image}",
                onEdit: () {
                  // TODO: EDIT nih
                },
                onDelete: () => actionDeleteMenu(menu),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff00C3FF),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MenuFormPage()),
          );

          if (result == true) {
            setState(() {
              _loadMenus();
            });
          }
        },
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
