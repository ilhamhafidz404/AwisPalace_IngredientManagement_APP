// lib/features/transaction/presentation/widgets/transaction_menu_item.dart

import 'package:flutter/material.dart';

class TransactionMenuItem extends StatelessWidget {
  final String nama;
  final String harga;
  final String gambar;
  final int quantity;
  final Function(int) onQuantityChanged;

  const TransactionMenuItem({
    super.key,
    required this.nama,
    required this.harga,
    required this.gambar,
    required this.quantity,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Gambar Menu
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                gambar,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: const Icon(Icons.restaurant, color: Colors.grey),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),

            // Info Menu
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nama,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    harga,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // Quantity Controls
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xff00C3FF)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // Button Minus
                  InkWell(
                    onTap: () {
                      if (quantity > 0) {
                        onQuantityChanged(quantity - 1);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.remove,
                        size: 20,
                        color: Color(0xff00C3FF),
                      ),
                    ),
                  ),

                  // Quantity Display
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      quantity.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Button Plus
                  InkWell(
                    onTap: () {
                      onQuantityChanged(quantity + 1);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.add,
                        size: 20,
                        color: Color(0xff00C3FF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
