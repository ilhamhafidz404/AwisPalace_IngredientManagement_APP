import 'package:flutter/material.dart';
import 'package:ingredient_management_app/utils/range_date_indonesian_style.dart';

class DashboardFilterCard extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final VoidCallback onPickDate;
  final VoidCallback? onReset;

  const DashboardFilterCard({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onPickDate,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Transaksi",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  FormatDateRangeIndonesianStyle(startDate, endDate),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Row(
            children: [
              TextButton.icon(
                onPressed: onPickDate,
                icon: const Icon(Icons.filter_alt, size: 18),
                label: const Text("Filter"),
                style: TextButton.styleFrom(foregroundColor: Colors.white),
              ),
              IconButton(
                onPressed: onReset,
                icon: const Icon(Icons.refresh, size: 18, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
