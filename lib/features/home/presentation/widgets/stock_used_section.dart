import 'package:flutter/material.dart';
import 'ingredient_section.dart';

class StockUsedSection extends StatelessWidget {
  final List ingredients;

  const StockUsedSection({super.key, required this.ingredients});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Stok yang digunakan",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ingredients.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    "Belum ada stok yang digunakan",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            : IngredientSection(ingredients: ingredients),
      ],
    );
  }
}
