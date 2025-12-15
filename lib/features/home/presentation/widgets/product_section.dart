// lib/features/home/presentation/widgets/product_section.dart

import 'package:flutter/material.dart';
import 'package:ingredient_management_app/features/home/presentation/widgets/product_card.dart';
import 'package:ingredient_management_app/widgets/custom_button.dart';

class ProductSection extends StatefulWidget {
  final List<dynamic> menus;

  const ProductSection({super.key, required this.menus});

  @override
  State<ProductSection> createState() => _ProductSectionState();
}

class _ProductSectionState extends State<ProductSection> {
  int visibleCount = 3;

  @override
  Widget build(BuildContext context) {
    final visibleProducts = widget.menus.take(visibleCount).toList();

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: visibleProducts.length,
          itemBuilder: (context, index) {
            final item = visibleProducts[index];
            return ProductCard(
              imagePath: "assets/img/nasigoreng.png", // Default image
              title: item['name'],
              subtitle: "Tersedia: ${item['quantity']} Porsi",
            );
          },
        ),

        const SizedBox(height: 16),

        // Tombol Show More/Less
        if (widget.menus.length > 3)
          visibleCount < widget.menus.length
              ? CustomButton(
                  label: "Lihat lebih banyak",
                  onPressed: () {
                    setState(() {
                      visibleCount += 3;
                    });
                  },
                )
              : CustomButton(
                  label: "Lihat lebih sedikit",
                  onPressed: () {
                    setState(() {
                      visibleCount = 3;
                    });
                  },
                ),
      ],
    );
  }
}
