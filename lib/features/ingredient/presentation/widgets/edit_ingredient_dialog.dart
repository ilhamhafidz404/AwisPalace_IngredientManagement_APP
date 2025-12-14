import 'package:flutter/material.dart';
import 'package:ingredient_management_app/models/unit_model.dart';
import 'package:ingredient_management_app/services/unit_service.dart';

class EditIngredientDialog extends StatefulWidget {
  final String initialName;
  final int initialStock;
  final int initialUnitId;

  final Function(String name, int stock, int unitId) onSave;

  const EditIngredientDialog({
    super.key,
    required this.initialName,
    required this.initialStock,
    required this.initialUnitId,
    required this.onSave,
  });

  @override
  State<EditIngredientDialog> createState() => _EditIngredientDialogState();
}

class _EditIngredientDialogState extends State<EditIngredientDialog> {
  late TextEditingController nameC;
  late TextEditingController stockC;

  List<UnitModel> units = [];
  int? selectedUnitId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    nameC = TextEditingController(text: widget.initialName);
    stockC = TextEditingController(text: widget.initialStock.toString());
    selectedUnitId = widget.initialUnitId;

    _loadUnits();
  }

  Future<void> _loadUnits() async {
    try {
      final result = await UnitService.getUnits();
      setState(() {
        units = result;
        isLoading = false;
      });
    } catch (e) {
      isLoading = false;
    }
  }

  @override
  void dispose() {
    nameC.dispose();
    stockC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text("Edit Bahan"),

      content: isLoading
          ? const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// NAMA
                  TextField(
                    controller: nameC,
                    decoration: const InputDecoration(
                      labelText: "Nama Bahan",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// STOCK
                  TextField(
                    controller: stockC,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Stock",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// UNIT DROPDOWN
                  DropdownButtonFormField<int>(
                    value: selectedUnitId,
                    decoration: const InputDecoration(
                      labelText: "Satuan",
                      border: OutlineInputBorder(),
                    ),
                    items: units
                        .map(
                          (u) => DropdownMenuItem<int>(
                            value: u.id,
                            child: Text("${u.name} (${u.symbol})"),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedUnitId = val;
                      });
                    },
                  ),
                ],
              ),
            ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal"),
        ),

        ElevatedButton(
          onPressed: isLoading
              ? null
              : () {
                  final name = nameC.text.trim();
                  final stock = int.tryParse(stockC.text) ?? 0;

                  if (name.isEmpty || selectedUnitId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Semua field wajib diisi")),
                    );
                    return;
                  }

                  widget.onSave(name, stock, selectedUnitId!);
                },
          child: const Text("Simpan"),
        ),
      ],
    );
  }
}
