import 'package:flutter/material.dart';

class EditMenuDialog extends StatelessWidget {
  final TextEditingController namaC;
  final TextEditingController stokC;
  final VoidCallback onSave;

  const EditMenuDialog({
    super.key,
    required this.namaC,
    required this.stokC,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text("Edit Menu"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: namaC,
            decoration: const InputDecoration(labelText: "Nama menu"),
          ),
          TextField(
            controller: stokC,
            decoration: const InputDecoration(labelText: "Stok"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal"),
        ),
        ElevatedButton(onPressed: onSave, child: const Text("Simpan")),
      ],
    );
  }
}
