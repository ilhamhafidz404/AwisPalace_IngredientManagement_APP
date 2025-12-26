import 'package:flutter/material.dart';
import 'package:ingredient_management_app/features/menu/data/models/menu_model.dart';
import 'package:ingredient_management_app/features/menu/data/services/menu_service.dart';
import 'package:ingredient_management_app/features/transaction/data/services/transaction_service.dart';
import 'package:ingredient_management_app/features/transaction/presentation/widgets/transaction_menu_item.dart';
import 'package:ingredient_management_app/utils/currency_extension.dart';
import 'package:ingredient_management_app/widgets/custom_app_bar.dart';
import 'package:ingredient_management_app/widgets/custom_bottom_nav_handler.dart';
import '../../../../widgets/custom_bottom_nav.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final int _selectedIndex = 3; // Index untuk "Hitung"
  late Future<List<MenuModel>> menusFuture;

  // Map untuk menyimpan quantity setiap menu
  Map<int, int> menuQuantities = {};

  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadMenus();
  }

  void _loadMenus() {
    menusFuture = MenuService.fetchMenus();
  }

  /// Update quantity menu
  void _updateQuantity(int menuId, int newQuantity) {
    setState(() {
      if (newQuantity <= 0) {
        menuQuantities.remove(menuId);
      } else {
        menuQuantities[menuId] = newQuantity;
      }
    });
  }

  /// Hitung total harga
  double _calculateTotal(List<MenuModel> menus) {
    double total = 0;
    menuQuantities.forEach((menuId, quantity) {
      final menu = menus.firstWhere((m) => m.id == menuId);
      total += menu.price * quantity;
    });
    return total;
  }

  /// Proses transaksi
  Future<void> _processTransaction(List<MenuModel> menus) async {
    if (menuQuantities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pilih menu terlebih dahulu"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      final items = menuQuantities.entries
          .map((entry) => {'menu_id': entry.key, 'quantity': entry.value})
          .toList();

      final result = await TransactionService.createTransaction(
        items: items,
        notes: 'Transaksi dari aplikasi',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Transaksi berhasil!\nKode: ${result['transaction_code']}\nTotal: Rp ${result['total_amount'].toStringAsFixed(0)}",
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // Reset form
      setState(() {
        menuQuantities.clear();
      });
    } catch (e) {
      // Gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal memproses transaksi: $e"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF00B3E6),
        elevation: 0,
        title: const Text(
          "Hitung Pendapatan",
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

          final total = _calculateTotal(menus);

          return Column(
            children: [
              // List Menu
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: menus.length,
                  itemBuilder: (context, index) {
                    final menu = menus[index];
                    final quantity = menuQuantities[menu.id] ?? 0;

                    return TransactionMenuItem(
                      nama: menu.name,
                      harga: menu.price.toRupiah(),
                      gambar:
                          "http://alope.site:8080/uploads/${menu.image}", // sementara
                      quantity: quantity,
                      onQuantityChanged: (newQuantity) {
                        _updateQuantity(menu.id, newQuantity);
                      },
                    );
                  },
                ),
              ),

              // Bottom Section: Total & Button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${total.toRupiah()}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff00C3FF),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Button Proses
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isProcessing
                            ? null
                            : () => _processTransaction(menus),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff00C3FF),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isProcessing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Proses Transaksi",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _selectedIndex,
        onItemTapped: (i) =>
            CustomBottomNavHandler.onItemTapped(context, _selectedIndex, i),
      ),
    );
  }
}
