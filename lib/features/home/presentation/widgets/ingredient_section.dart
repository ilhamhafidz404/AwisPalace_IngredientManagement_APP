// lib/features/home/presentation/widgets/ingredient_section.dart

import 'package:flutter/material.dart';
import 'package:ingredient_management_app/features/home/presentation/widgets/badge_widget.dart';
import 'package:ingredient_management_app/widgets/custom_button.dart';

class IngredientSection extends StatefulWidget {
  final List<dynamic> ingredients;

  const IngredientSection({super.key, required this.ingredients});

  @override
  State<IngredientSection> createState() => _IngredientSectionState();
}

class _IngredientSectionState extends State<IngredientSection> {
  int visibleCount = 10;

  @override
  Widget build(BuildContext context) {
    final visibleItems = widget.ingredients.take(visibleCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: visibleItems
              .map(
                (item) => BadgeWidget(
                  label:
                      "${item['quantity'].toStringAsFixed(1)} ${item['unit']} ${item['name']}",
                  backgroundColor: const Color(0xFFEAD3FF),
                  textColor: Colors.black,
                ),
              )
              .toList(),
        ),

        const SizedBox(height: 25),

        if (widget.ingredients.length > 10)
          Center(
            child: visibleCount < widget.ingredients.length
                ? CustomButton(
                    label: "Lihat lebih banyak",
                    onPressed: () {
                      setState(() {
                        visibleCount += 10;
                      });
                    },
                  )
                : CustomButton(
                    label: "Lihat lebih sedikit",
                    onPressed: () {
                      setState(() {
                        visibleCount = 10;
                      });
                    },
                  ),
          ),
      ],
    );
  }
}
