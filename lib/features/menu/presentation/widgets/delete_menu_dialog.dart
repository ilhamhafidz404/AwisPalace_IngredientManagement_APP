import 'package:flutter/material.dart';

class DeleteMenuDialog extends StatelessWidget {
  final String menuName;
  final VoidCallback onDelete;

  const DeleteMenuDialog({
    super.key,
    required this.menuName,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text("Hapus Menu?"),
      content: Text("Yakin ingin menghapus \"$menuName\"?"),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: onDelete,
          child: const Text("Hapus"),
        ),
      ],
    );
  }
}
