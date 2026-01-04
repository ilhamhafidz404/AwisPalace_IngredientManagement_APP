import 'package:flutter/material.dart';
import 'package:ingredient_management_app/features/menu/presentation/pages/menu_detail_page.dart';

class MenuCard extends StatelessWidget {
  final int menuId;
  final String nama;
  final String price;
  final String gambar;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MenuCard({
    super.key,
    required this.menuId,
    required this.nama,
    required this.price,
    required this.gambar,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(Colors.white.value),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MenuDetailPage(menuId: menuId)),
          );
        },

        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 7),

          /// IMAGE
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              gambar,
              width: 100,
              height: 150,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const SizedBox(
                  width: 100,
                  height: 150,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
              errorBuilder: (_, __, ___) => Container(
                width: 100,
                height: 150,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, size: 40),
              ),
            ),
          ),

          /// TITLE
          title: Text(
            nama,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),

          /// PRICE
          subtitle: Text(price),

          /// ACTIONS
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
