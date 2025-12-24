// lib/features/home/presentation/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:ingredient_management_app/features/home/data/services/home_service.dart';
import 'package:ingredient_management_app/features/home/presentation/widgets/ingredient_section.dart';
import 'package:ingredient_management_app/features/home/presentation/widgets/product_section.dart';
import 'package:ingredient_management_app/features/home/presentation/widgets/menu_bar_chart.dart';
import 'package:ingredient_management_app/utils/range_date_indonesian_style.dart';
import 'package:ingredient_management_app/widgets/custom_bottom_nav.dart';
import 'package:ingredient_management_app/widgets/custom_bottom_nav_handler.dart';

/// ======================
/// ENUM VIEW MODE
/// ======================
enum MenuViewMode { list, chart }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  late Future<Map<String, dynamic>> dashboardFuture;

  late DateTime startDate;
  late DateTime endDate;

  late DateTime _defaultStartDate;
  late DateTime _defaultEndDate;

  /// MODE LIST / CHART
  MenuViewMode menuViewMode = MenuViewMode.list;

  @override
  void initState() {
    super.initState();
    _initDefaultDate();
    _loadDashboard();
  }

  /// ======================
  /// INIT DEFAULT (MINGGU INI)
  /// ======================
  void _initDefaultDate() {
    final now = DateTime.now();
    final weekday = now.weekday; // Senin = 1

    _defaultStartDate = DateTime(now.year, now.month, now.day - (weekday - 1));
    _defaultEndDate = _defaultStartDate.add(const Duration(days: 6));

    startDate = _defaultStartDate;
    endDate = _defaultEndDate;
  }

  /// ======================
  /// LOAD DASHBOARD
  /// ======================
  void _loadDashboard() {
    dashboardFuture = HomeService.getDashboard(
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// ======================
  /// DATE RANGE PICKER
  /// ======================
  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final lastAllowedDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: lastAllowedDate,
      initialDateRange: DateTimeRange(
        start: startDate,
        end: endDate.isAfter(lastAllowedDate) ? lastAllowedDate : endDate,
      ),
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
        _loadDashboard();
      });
    }
  }

  /// ======================
  /// RESET FILTER
  /// ======================
  void _resetFilter() {
    setState(() {
      startDate = _defaultStartDate;
      endDate = _defaultEndDate;
      _loadDashboard();
    });
  }

  bool get _isDefaultRange =>
      startDate == _defaultStartDate && endDate == _defaultEndDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// ======================
      /// APP BAR
      /// ======================
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF00B3E6),
        elevation: 0,
        title: const Text(
          "Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      /// ======================
      /// BODY
      /// ======================
      body: FutureBuilder<Map<String, dynamic>>(
        future: dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

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
                    onPressed: _loadDashboard,
                    child: const Text("Coba Lagi"),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!;
          final menus = (data['menus'] ?? []) as List;
          final ingredients = (data['ingredients'] ?? []) as List;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ======================
                /// CARD FILTER
                /// ======================
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00B3E6), Color(0xFF0088CC)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "Transaksi ${FormatDateRangeIndonesianStyle(startDate, endDate)}",
                          style: const TextStyle(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: _pickDateRange,
                            icon: const Icon(Icons.filter_alt, size: 18),
                            label: const Text("Filter"),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                            ),
                          ),
                          TextButton(
                            onPressed: _isDefaultRange ? null : _resetFilter,
                            child: const Text("Reset"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                /// ======================
                /// MENU TERJUAL + TOGGLE
                /// ======================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Menu yang Terjual",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ToggleButtons(
                      isSelected: [
                        menuViewMode == MenuViewMode.list,
                        menuViewMode == MenuViewMode.chart,
                      ],
                      onPressed: (index) {
                        setState(() {
                          menuViewMode = index == 0
                              ? MenuViewMode.list
                              : MenuViewMode.chart;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(Icons.list),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(Icons.bar_chart),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                menus.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text(
                            "Belum ada menu yang terjual",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    : menuViewMode == MenuViewMode.list
                    ? ProductSection(menus: menus)
                    : MenuBarChart(menus: menus),

                const SizedBox(height: 32),

                /// ======================
                /// STOK DIGUNAKAN
                /// ======================
                const Text(
                  "Stok yang digunakan",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                ingredients.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text(
                            "Belum ada stok yang digunakan",
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

      /// ======================
      /// BOTTOM NAV
      /// ======================
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: currentIndex,
        onItemTapped: (i) =>
            CustomBottomNavHandler.onItemTapped(context, currentIndex, i),
      ),
    );
  }
}
