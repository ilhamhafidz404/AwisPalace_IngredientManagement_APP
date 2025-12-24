import 'package:flutter/material.dart';
import 'package:ingredient_management_app/features/menu/presentation/pages/menu_detail_page.dart';

class MenuCard extends StatelessWidget {
  final String nama;
  final String price;
  final String gambar;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MenuCard({
    super.key,
    required this.nama,
    required this.price,
    required this.gambar,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MenuDetailPage(nama: nama, gambar: gambar),
            ),
          );
        },
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 7),

          leading: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              gambar,
              width: 100,
              height: 150,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const SizedBox(
                  width: 100,
                  height: 150,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100,
                  height: 150,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 40),
                );
              },
            ),
          ),

          title: Text(
            nama,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),

          subtitle: Text("$price"),

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
