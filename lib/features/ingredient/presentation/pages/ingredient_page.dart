import 'package:flutter/material.dart';
import 'package:ingredient_management_app/features/ingredient/data/models/ingredient_model.dart';
import 'package:ingredient_management_app/features/ingredient/data/services/ingredient_service.dart';
import 'package:ingredient_management_app/features/ingredient/presentation/widgets/created_ingredient_dialog.dart';
import 'package:ingredient_management_app/features/ingredient/presentation/widgets/delete_ingredient_dialog.dart';
import 'package:ingredient_management_app/features/ingredient/presentation/widgets/edit_ingredient_dialog.dart';
import 'package:ingredient_management_app/widgets/custom_bottom_nav.dart';
import 'package:ingredient_management_app/widgets/custom_bottom_nav_handler.dart';

class IngredientPage extends StatefulWidget {
  const IngredientPage({super.key});

  @override
  State<IngredientPage> createState() => _IngredientPageState();
}

class _IngredientPageState extends State<IngredientPage> {
  final int currentIndex = 2;

  late Future<List<IngredientModel>> ingredientFuture;

  @override
  void initState() {
    super.initState();
    _loadIngredients();
  }

  void _loadIngredients() {
    ingredientFuture = IngredientService.getIngredients();
  }

  /// =================== EDIT ===================ingredientFuture = IngredientService.getIngredients();
  void editItem(IngredientModel item) {
    showDialog(
      context: context,
      builder: (_) => EditIngredientDialog(
        initialName: item.name,
        initialStock: item.stock,
        initialUnitId: item.unitId,
        onSave: (name, stock, unitId) async {
          try {
            await IngredientService.updateIngredient(
              id: item.id,
              name: name,
              stock: stock,
              unitId: unitId,
            );

            Navigator.pop(context);

            setState(() {
              ingredientFuture = IngredientService.getIngredients();
            });
          } catch (e) {
            Navigator.pop(context);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Gagal update: $e")));
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
      print("DELETE START");
      await IngredientService.deleteIngredient(item.id);
      print("DELETE DONE");

      setState(() {
        ingredientFuture = IngredientService.getIngredients();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ingredient berhasil dihapus"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
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

      body: FutureBuilder<List<IngredientModel>>(
        future: ingredientFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Terjadi kesalahan:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final ingredients = snapshot.data!;

          if (ingredients.isEmpty) {
            return const Center(child: Text("Belum ada data bahan"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: ingredients.length,
            itemBuilder: (context, index) {
              final item = ingredients[index];

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
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  subtitle: Text("Tersedia: ${item.stock} ${item.unitSymbol}"),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => editItem(item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteItem(item),
                      ),
                    ],
                  ),
                ),
              );
            },
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
              onSubmit: (name, stock, unitId) async {
                await IngredientService.createIngredient(
                  name: name,
                  stock: stock,
                  unitId: unitId,
                );
                setState(() {
                  ingredientFuture = IngredientService.getIngredients();
                });
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
