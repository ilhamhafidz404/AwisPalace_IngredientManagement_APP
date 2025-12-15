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
    // 1. Tampilkan dialog konfirmasi
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      // Panggil DeleteMenuDialog, DIALOG AKAN MENGEMBALIKAN TRUE/FALSE
      builder: (_) => DeleteMenuDialog(
        menuName: menu.name,
        // Hapus property onDelete (jika dialog Anda sudah dimodifikasi untuk mengembalikan bool)
        // Jika Anda TIDAK BISA memodifikasi DeleteMenuDialog, Anda harus memodifikasi kode di bawah ini
      ),
    );

    // User batal atau menutup dialog (confirm akan bernilai null atau false)
    if (confirm != true) return;

    try {
      // Logic penghapusan hanya berjalan jika confirm == true

      print("DELETE MENU START: ${menu.name}");

      // 2. Panggil MenuService untuk menghapus menu
      await MenuService.deleteMenu(menu.id);

      print("DELETE MENU DONE");

      // 3. Update daftar menu setelah penghapusan berhasil
      setState(() {
        _loadMenus();
      });

      // 4. Tampilkan notifikasi sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Menu '${menu.name}' berhasil dihapus"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // 5. Tampilkan notifikasi error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal menghapus menu: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
    // Tidak perlu 'finally' karena tidak ada 'isLoading'
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
                gambar: "assets/img/nasigoreng.png", // sementara
                onEdit: () {
                  // TODO: arahkan ke halaman edit
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
              _loadMenus(); // reload menu
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
