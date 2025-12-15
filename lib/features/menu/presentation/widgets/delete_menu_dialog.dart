import 'package:flutter/material.dart';

class DeleteMenuDialog extends StatelessWidget {
  final String menuName;
  // Hapus: final VoidCallback onDelete; // Tidak diperlukan lagi

  const DeleteMenuDialog({
    super.key,
    required this.menuName,
    // Hapus: required this.onDelete, // Tidak diperlukan lagi
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text("Hapus Menu?"),
      content: Text("Yakin ingin menghapus \"$menuName\"?"),
      actions: [
        // Tombol Batal
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
          onPressed: () =>
              Navigator.pop(context, false), // <--- MENGEMBALIKAN FALSE
          child: const Text("Batal"),
        ),

        // Tombol Hapus (Konfirmasi)
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          // Aksi: Mengembalikan TRUE untuk mengonfirmasi penghapusan
          onPressed: () =>
              Navigator.pop(context, true), // <--- MENGEMBALIKAN TRUE
          child: const Text("Hapus"),
        ),
      ],
    );
  }
}
