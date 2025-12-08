import 'package:flutter/material.dart';
import 'package:ingredient_management_app/features/home/presentation/widgets/alert.dart';
import 'package:ingredient_management_app/features/home/presentation/widgets/ingredient_section.dart';
import 'package:ingredient_management_app/features/home/presentation/widgets/product_section.dart';
import 'package:ingredient_management_app/widgets/custom_bottom_nav.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: const Color(0xFF00B3E6),
        elevation: 0,
        title: const Text(
          "Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.search, color: Colors.white, size: 28),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AlertWidget(
              title: "PERINGATAN!",
              message: "Stok Nasi Goreng Hampir Habis",
            ),

            const SizedBox(height: 24),

            const Text(
              "Menu yang Terjual:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const ProductSection(),

            const SizedBox(height: 40),

            const Text(
              "Stok yang digunakan:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            const IngredientSection(),
          ],
        ),
      ),

      bottomNavigationBar: CustomBottomNav(
        selectedIndex: currentIndex,
        onItemTapped: (index) {
          setState(() => currentIndex = index);

          if (index == 0) Navigator.pushNamed(context, '/beranda');
          if (index == 1) return;
          if (index == 2) Navigator.pushNamed(context, '/kelola');
          if (index == 3) Navigator.pushNamed(context, '/menu');
          if (index == 4) Navigator.pushNamed(context, '/profile');
        },
      ),
    );
  }
}
