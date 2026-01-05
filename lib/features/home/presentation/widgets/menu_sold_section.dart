import 'package:flutter/material.dart';
import '../pages/home_page.dart';

class MenuSoldSection extends StatelessWidget {
  final MenuViewMode mode;
  final List menus;
  final ValueChanged<MenuViewMode> onChangeMode;
  final Widget listView;
  final Widget chartView;

  const MenuSoldSection({
    super.key,
    required this.mode,
    required this.menus,
    required this.onChangeMode,
    required this.listView,
    required this.chartView,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Menu yang Terjual",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ToggleButtons(
              isSelected: [
                mode == MenuViewMode.list,
                mode == MenuViewMode.chart,
              ],
              onPressed: (i) =>
                  onChangeMode(i == 0 ? MenuViewMode.list : MenuViewMode.chart),
              color: Colors.grey[600], // Warna icon tidak aktif
              selectedColor: const Color(0xFF00B3E6), // Warna icon aktif
              fillColor: const Color(
                0xFF00B3E6,
              ).withOpacity(0.1), // Background aktif
              borderColor: Colors.grey.shade300,
              selectedBorderColor: const Color(0xFF00B3E6).withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              borderWidth: 1.5,
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Icon(Icons.list, size: 24),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Icon(Icons.bar_chart, size: 24),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        menus.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    "Belum ada menu yang terjual",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            : mode == MenuViewMode.list
            ? listView
            : chartView,
      ],
    );
  }
}
