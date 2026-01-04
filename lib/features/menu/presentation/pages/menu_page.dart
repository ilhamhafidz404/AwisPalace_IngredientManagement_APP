import 'package:flutter/material.dart';
import 'package:ingredient_management_app/features/menu/data/models/menu_model.dart';
import 'package:ingredient_management_app/features/menu/data/services/menu_service.dart';
import 'package:ingredient_management_app/features/menu/presentation/pages/menu_form_page.dart';
import 'package:ingredient_management_app/features/menu/presentation/widgets/delete_menu_dialog.dart';
import 'package:ingredient_management_app/features/menu/presentation/widgets/menu_card.dart';
import 'package:ingredient_management_app/utils/currency_extension.dart';
import 'package:ingredient_management_app/widgets/custom_app_bar.dart';
import 'package:ingredient_management_app/widgets/custom_bottom_nav_handler.dart';
import 'package:ingredient_management_app/widgets/error_page.dart';
import 'package:intl/intl.dart';
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

  /// ===================== EDIT MENU ==========================
  void actionEditMenu(MenuModel menu) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MenuFormPage(menu: menu)),
    );

    if (result == true) {
      setState(() {
        _loadMenus();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Menu '${menu.name}' berhasil diperbarui"),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Menu '${menu.name}' berhasil dihapus"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal menghapus menu: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// ===================== ADD MENU ==========================
  void actionAddMenu() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MenuFormPage()),
    );

    if (result == true) {
      setState(() {
        _loadMenus();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Menu berhasil ditambahkan"),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  //
  final rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// ========================== UI ==============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF00B3E6),
        elevation: 0,
        title: const Text(
          "Kelola Menu",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          CustomAppBar(
            onRefresh: _loadMenus,
            onLogout: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
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
            return ErrorPage(
              title: "Gagal Memuat Menu",
              error: snapshot.error,
              onRetry: () {
                setState(() {
                  _loadMenus();
                });
              },
            );
          }

          final menus = snapshot.data!;

          if (menus.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Menu masih kosong",
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tap tombol + untuk menambahkan menu",
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: Colors.blue.shade700,
            onRefresh: () async {
              setState(() {
                _loadMenus();
              });
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: menus.length,
              itemBuilder: (context, index) {
                final menu = menus[index];

                return MenuCard(
                  menuId: menu.id,
                  nama: menu.name,
                  price: menu.price.toRupiah(),
                  gambar: "http://alope.site:8080/uploads/${menu.image}",
                  onEdit: () => actionEditMenu(menu),
                  onDelete: () => actionDeleteMenu(menu),
                );
              },
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff00C3FF),
        onPressed: actionAddMenu,
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
