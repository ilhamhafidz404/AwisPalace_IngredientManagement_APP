import 'package:flutter/material.dart';

class DeleteIngredientDialog extends StatelessWidget {
  final String name;

  const DeleteIngredientDialog({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text("Hapus Bahan"),
      content: Text("Yakin ingin menghapus \"$name\"?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Batal"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            // ❗ HANYA RETURN TRUE
            Navigator.pop(context, true);
          },
          child: const Text("Hapus"),
        ),
      ],
    );
  }
}
