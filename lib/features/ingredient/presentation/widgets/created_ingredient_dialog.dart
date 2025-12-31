import 'package:flutter/material.dart';
import 'package:ingredient_management_app/models/unit_model.dart';
import 'package:ingredient_management_app/services/unit_service.dart';
import '../../data/models/ingredient_model.dart';

class CreateIngredientDialog extends StatefulWidget {
  final IngredientModel? ingredient;
  final Function(String name, double stock, int unitId) onSubmit;

  const CreateIngredientDialog({
    super.key,
    this.ingredient,
    required this.onSubmit,
  });

  @override
  State<CreateIngredientDialog> createState() => _CreateIngredientDialogState();
}

class _CreateIngredientDialogState extends State<CreateIngredientDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameC;
  late TextEditingController stockC;

  List<UnitModel> units = [];
  int? selectedUnitId;
  bool loadingUnit = true;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();

    nameC = TextEditingController(text: widget.ingredient?.name ?? "");
    stockC = TextEditingController(
      text: widget.ingredient?.stock.toString() ?? "",
    );

    selectedUnitId = widget.ingredient?.unitId;
    _loadUnits();
  }

  Future<void> _loadUnits() async {
    units = await UnitService.getUnits();
    if (selectedUnitId == null && units.isNotEmpty) {
      selectedUnitId = units.first.id;
    }
    setState(() => loadingUnit = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Text(
        widget.ingredient == null ? "Tambah Ingredient" : "Edit Ingredient",
      ),
      content: loadingUnit
          ? const SizedBox(
              height: 80,
              child: Center(child: CircularProgressIndicator()),
            )
          : Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// NAME
                  TextFormField(
                    controller: nameC,
                    decoration: const InputDecoration(
                      labelText: "Nama Ingredient",
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? "Wajib diisi" : null,
                  ),

                  const SizedBox(height: 12),

                  /// STOCK (DOUBLE)
                  TextFormField(
                    controller: stockC,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: "Stok"),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "Wajib diisi";
                      }
                      if (double.tryParse(v) == null) {
                        return "Harus berupa angka";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  /// UNIT
                  DropdownButtonFormField<int>(
                    value: selectedUnitId,
                    decoration: const InputDecoration(labelText: "Unit"),
                    items: units
                        .map(
                          (u) => DropdownMenuItem(
                            value: u.id,
                            child: Text("${u.name} (${u.symbol})"),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => selectedUnitId = v),
                    validator: (v) => v == null ? "Pilih unit" : null,
                  ),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: isSubmitting ? null : () => Navigator.pop(context),
          child: const Text("Batal"),
        ),
        ElevatedButton(
          onPressed: isSubmitting
              ? null
              : () {
                  if (!_formKey.currentState!.validate()) return;

                  setState(() => isSubmitting = true);

                  widget.onSubmit(
                    nameC.text.trim(),
                    double.parse(stockC.text),
                    selectedUnitId!,
                  );
                },
          child: isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text("Simpan"),
        ),
      ],
    );
  }
}
