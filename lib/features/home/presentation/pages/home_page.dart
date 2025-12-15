// lib/features/home/presentation/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:ingredient_management_app/features/home/data/services/home_service.dart';
import 'package:ingredient_management_app/features/home/presentation/widgets/alert.dart';
import 'package:ingredient_management_app/features/home/presentation/widgets/ingredient_section.dart';
import 'package:ingredient_management_app/features/home/presentation/widgets/product_section.dart';
import 'package:ingredient_management_app/widgets/custom_bottom_nav.dart';
import 'package:ingredient_management_app/widgets/custom_bottom_nav_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  late Future<Map<String, dynamic>> dashboardFuture;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  void _loadDashboard() {
    dashboardFuture = HomeService.getTodayDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF00B3E6),
        elevation: 0,
        title: const Text(
          "Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                _loadDashboard();
              });
            },
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.search, color: Colors.white, size: 28),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: dashboardFuture,
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    "Gagal memuat data\n${snapshot.error}",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loadDashboard();
                      });
                    },
                    child: const Text("Coba Lagi"),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!;
          final menus = data['menus'] as List;
          final ingredients = data['ingredients'] as List;
          final totalTransactions = data['total_transactions'] as int;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Card - Total Transaksi Hari Ini
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00B3E6), Color(0xFF0088CC)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Transaksi Hari Ini",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$totalTransactions Transaksi",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Alert jika ada
                // const AlertWidget(
                //   title: "PERINGATAN!",
                //   message: "Stok Nasi Goreng Hampir Habis",
                // ),
                // const SizedBox(height: 24),
                const Text(
                  "Menu yang Terjual:",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // Product Section dengan data dari API
                menus.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text(
                            "Belum ada menu yang terjual hari ini",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    : ProductSection(menus: menus),

                const SizedBox(height: 40),

                const Text(
                  "Stok yang digunakan:",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // Ingredient Section dengan data dari API
                ingredients.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text(
                            "Belum ada stok yang digunakan hari ini",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    : IngredientSection(ingredients: ingredients),
              ],
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
