import 'package:flutter/material.dart';

class LowStockAlertDialog extends StatelessWidget {
  final List<String> items;

  const LowStockAlertDialog({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final message = '${items.join(', ')} sudah mulai habis';

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange),
          SizedBox(width: 8),
          Text('Peringatan Stok'),
        ],
      ),
      content: Text(message, style: const TextStyle(fontSize: 14)),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: const Text('Mengerti'),
        ),
      ],
    );
  }
}
