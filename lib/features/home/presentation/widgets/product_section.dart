import 'package:flutter/material.dart';
import 'package:ingredient_management_app/features/home/presentation/widgets/product_card.dart';
import 'package:ingredient_management_app/widgets/custom_button.dart';

final List<Map<String, String>> products = [
  {
    "image": "assets/img/nasigoreng.png",
    "title": "Nasi Goreng",
    "subtitle": "Tersedia: 4 Porsi",
  },
  {
    "image": "assets/img/nasigoreng.png",
    "title": "Mie Goreng",
    "subtitle": "Tersedia: 3 Porsi",
  },
  {
    "image": "assets/img/nasigoreng.png",
    "title": "Ayam Geprek",
    "subtitle": "Tersedia: 5 Porsi",
  },
  {
    "image": "assets/img/nasigoreng.png",
    "title": "Ayam Bakar",
    "subtitle": "Tersedia: 2 Porsi",
  },
  {
    "image": "assets/img/nasigoreng.png",
    "title": "Sate Ayam",
    "subtitle": "Tersedia: 6 Porsi",
  },
];

class ProductSection extends StatefulWidget {
  const ProductSection({super.key});

  @override
  State<ProductSection> createState() => _ProductSectionState();
}

class _ProductSectionState extends State<ProductSection> {
  int visibleCount = 3; // TAMPIL 3 MUTI AWAL

  @override
  Widget build(BuildContext context) {
    final visibleProducts = products.take(visibleCount).toList();

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
              imagePath: item["image"]!,
              title: item["title"]!,
              subtitle: item["subtitle"]!,
            );
          },
        ),

        const SizedBox(height: 16),

        // 🔥 TOMBOL LOGIC
        if (visibleCount < products.length)
          CustomButton(
            label: "Lihat lebih banyak",
            onPressed: () {
              setState(() {
                visibleCount += 3;
              });
            },
          )
        else
          CustomButton(
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
