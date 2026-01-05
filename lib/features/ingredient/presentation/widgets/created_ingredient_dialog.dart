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

  OutlineInputBorder _defaultBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.grey),
    );
  }

  OutlineInputBorder _focusedBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(
        color: Color(0xFF1976D2), // Blue 700
        width: 2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Text(widget.ingredient == null ? "Tambah Bahan" : "Edit Bahan"),
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
                    decoration: InputDecoration(
                      labelText: "Nama Bahan",
                      enabledBorder: _defaultBorder(),
                      focusedBorder: _focusedBorder(),
                      floatingLabelStyle: const TextStyle(
                        color: Color(0xFF1976D2),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? "Wajib diisi" : null,
                  ),

                  const SizedBox(height: 12),

                  /// STOCK
                  TextFormField(
                    controller: stockC,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: "Stok",
                      enabledBorder: _defaultBorder(),
                      focusedBorder: _focusedBorder(),
                      floatingLabelStyle: const TextStyle(
                        color: Color(0xFF1976D2),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
                    decoration: InputDecoration(
                      labelText: "Unit",
                      enabledBorder: _defaultBorder(),
                      focusedBorder: _focusedBorder(),
                      floatingLabelStyle: const TextStyle(
                        color: Color(0xFF1976D2),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
          child: const Text("Batal", style: TextStyle(color: Colors.black)),
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
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00B3E6),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
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
