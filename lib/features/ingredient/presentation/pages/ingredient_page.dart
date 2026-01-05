import 'package:flutter/material.dart';
import 'package:ingredient_management_app/features/ingredient/data/helpers/format_stock.dart';
import 'package:ingredient_management_app/features/ingredient/data/models/ingredient_model.dart';
import 'package:ingredient_management_app/features/ingredient/data/services/ingredient_service.dart';
import 'package:ingredient_management_app/features/ingredient/presentation/widgets/created_ingredient_dialog.dart';
import 'package:ingredient_management_app/features/ingredient/presentation/widgets/delete_ingredient_dialog.dart';
import 'package:ingredient_management_app/widgets/custom_app_bar.dart';
import 'package:ingredient_management_app/widgets/custom_bottom_nav.dart';
import 'package:ingredient_management_app/widgets/custom_bottom_nav_handler.dart';
import 'package:ingredient_management_app/widgets/error_page.dart';

class IngredientPage extends StatefulWidget {
  const IngredientPage({super.key});

  @override
  State<IngredientPage> createState() => _IngredientPageState();
}

class _IngredientPageState extends State<IngredientPage> {
  final int currentIndex = 2;

  late Future<List<IngredientModel>> ingredientFuture;

  Future<void> _onRefresh() async {
    setState(() {
      ingredientFuture = IngredientService.getIngredients();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadIngredients();
  }

  void _loadIngredients() {
    ingredientFuture = IngredientService.getIngredients();
  }

  bool isLowStock(double stock) {
    return stock <= 5;
  }

  /// ================= CREATE ============
  Future<void> _createIngredient(String name, double stock, int unitId) async {
    try {
      await IngredientService.createIngredient(
        name: name,
        stock: stock,
        unitId: unitId,
      );

      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop();

      setState(() {
        ingredientFuture = IngredientService.getIngredients();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Bahan '$name' berhasil ditambahkan"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal menambahkan bahan: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// =================== EDIT ===================
  void editItem(IngredientModel item) {
    showDialog(
      context: context,
      builder: (_) => CreateIngredientDialog(
        ingredient: item,
        onSubmit: (name, stock, unitId) async {
          try {
            await IngredientService.updateIngredient(
              id: item.id,
              name: name,
              stock: stock,
              unitId: unitId,
            );

            if (!mounted) return;
            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Bahan '$name' berhasil diperbarui"),
                backgroundColor: Colors.green,
              ),
            );

            setState(() {
              ingredientFuture = IngredientService.getIngredients();
            });
          } catch (e) {
            if (!mounted) return;
            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Gagal update: $e"),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  /// =================== DELETE ===================
  void deleteItem(IngredientModel item) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DeleteIngredientDialog(name: item.name),
    );

    // User batal
    if (confirm != true) return;

    try {
      await IngredientService.deleteIngredient(item.id);

      setState(() {
        ingredientFuture = IngredientService.getIngredients();
      });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Bahan '${item.name}' berhasil dihapus"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal Delete: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// ===================== UI ======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Kelola Bahan',
        onRefresh: _loadIngredients,
        onLogout: () =>
            Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false),
      ),

      body: FutureBuilder<List<IngredientModel>>(
        future: ingredientFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return ErrorPage(
              title: "Gagal Memuat Bahan",
              error: snapshot.error,
              onRetry: () {
                setState(() {
                  _loadIngredients();
                });
              },
            );
          }

          final ingredients = snapshot.data!;

          if (ingredients.isEmpty) {
            return const Center(child: Text("Belum ada data bahan"));
          }

          return RefreshIndicator(
            color: Colors.blue.shade700,
            onRefresh: _onRefresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: ingredients.length,
              itemBuilder: (context, index) {
                final item = ingredients[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isLowStock(item.stock)
                          ? Colors.red
                          : Colors.transparent,
                      width: 2,
                    ),
                    color: isLowStock(item.stock)
                        ? Colors.red.withOpacity(0.05)
                        : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    title: Text(
                      item.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isLowStock(item.stock)
                            ? Colors.red
                            : Colors.black,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        "Stok: ${formatStock(item.stock)} ${item.unitSymbol}",
                        style: TextStyle(
                          fontSize: 13,
                          color: isLowStock(item.stock)
                              ? Colors.red.shade700
                              : Colors.grey.shade700,
                          fontWeight: isLowStock(item.stock)
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          color: Colors.blue,
                          onPressed: () => editItem(item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () => deleteItem(item),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff00C3FF),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => CreateIngredientDialog(
              onSubmit: (name, stock, unitId) {
                _createIngredient(name, stock.toDouble(), unitId);
              },
            ),
          );
        },
      ),

      bottomNavigationBar: CustomBottomNav(
        selectedIndex: currentIndex,
        onItemTapped: (i) =>
            CustomBottomNavHandler.onItemTapped(context, currentIndex, i),
      ),
    );
  }
}
