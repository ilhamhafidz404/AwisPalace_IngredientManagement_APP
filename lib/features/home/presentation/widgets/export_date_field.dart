import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExportDateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const ExportDateField({
    super.key,
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  date != null
                      ? DateFormat('dd MMMM yyyy').format(date!)
                      : 'Pilih tanggal',
                  style: TextStyle(
                    fontSize: 14,
                    color: date != null ? Colors.black87 : Colors.grey[400],
                  ),
                ),
              ],
            ),
            Icon(Icons.calendar_today, color: Colors.blue[700]),
          ],
        ),
      ),
    );
  }
}
