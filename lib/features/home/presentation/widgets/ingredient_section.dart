import 'package:flutter/material.dart';
import 'package:ingredient_management_app/features/home/presentation/widgets/badge_widget.dart';
import 'package:ingredient_management_app/widgets/custom_button.dart';

class IngredientSection extends StatefulWidget {
  const IngredientSection({super.key});

  @override
  State<IngredientSection> createState() => _IngredientSectionState();
}

// DATA INGREDIENTS
final List<String> ingredients = [
  "1 Pcs Masako",
  "1 Siung Daun Jeruk",
  "2 Pcs Bumbu Racik",
  "2 Sendok Garam",
  "2 Butir Bawang Merah",
  "1 Sct Kecap",
  "1 Sdt Lada Bubuk",
  "1 Sct Kaldu Ayam",
  "1 Pcs Masako",
  "1 Siung Daun Jeruk",
  "2 Pcs Bumbu Racik",
  "2 Sendok Garam",
  "2 Butir Bawang Merah",
  "1 Sct Kecap",
];

class _IngredientSectionState extends State<IngredientSection> {
  int visibleCount = 10;

  @override
  Widget build(BuildContext context) {
    final visibleItems = ingredients.take(visibleCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: visibleItems
              .map(
                (item) => BadgeWidget(
                  label: item,
                  backgroundColor: const Color(0xFFEAD3FF),
                  textColor: Colors.black,
                ),
              )
              .toList(),
        ),

        const SizedBox(height: 25),

        Center(
          child: visibleCount < ingredients.length
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
