import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ingredient_management_app/features/ingredient/data/services/ingredient_service.dart';
import 'package:ingredient_management_app/services/unit_service.dart';
import '../../data/services/menu_service.dart';
import '../../data/models/menu_model.dart';

// ==================== MODELS ====================

class MasterIngredientModel {
  final int id;
  final String name;
  final int? unitId; // Add unit_id from ingredient
  final String? unitName; // Add unit_name from ingredient

  MasterIngredientModel({
    required this.id,
    required this.name,
    this.unitId,
    this.unitName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MasterIngredientModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class MasterUnitModel {
  final int id;
  final String name;

  MasterUnitModel({required this.id, required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MasterUnitModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class IngredientFormModel {
  MasterIngredientModel? ingredient;
  double quantity;
  MasterUnitModel? unit;

  IngredientFormModel({this.ingredient, this.quantity = 0.0, this.unit});

  Map<String, dynamic> toJson() => {
    "ingredient_id": ingredient?.id ?? 0,
    "quantity": quantity,
    "unit_id": unit?.id ?? 0,
  };
}

// ==================== CONSTANTS ====================

const Color primaryColor = Color(0xff00C3FF);
const double defaultPadding = 16.0;
const double fieldSpacing = 16.0;

// ==================== MAIN PAGE ====================

class MenuFormPage extends StatefulWidget {
  final MenuModel? menu;

  const MenuFormPage({super.key, this.menu});

  @override
  State<MenuFormPage> createState() => _MenuFormPageState();
}

class _MenuFormPageState extends State<MenuFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController nameC;
  late TextEditingController priceC;
  late TextEditingController descC;

  // Image
  String? _currentImageUrl;
  XFile? _imageFile;

  // Ingredients
  List<IngredientFormModel> ingredients = [];

  // Master Data
  List<MasterIngredientModel> masterIngredients = [];
  List<MasterUnitModel> masterUnits = [];

  // States
  bool isLoading = false;
  bool isMasterLoading = true;

  bool get isEdit => widget.menu != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadMasterData();
    _initializeIngredients();
  }

  @override
  void dispose() {
    nameC.dispose();
    priceC.dispose();
    descC.dispose();
    super.dispose();
  }

  // ==================== INITIALIZATION ====================

  void _initializeControllers() {
    nameC = TextEditingController(text: widget.menu?.name ?? "");
    priceC = TextEditingController(
      text: widget.menu != null ? widget.menu!.price.toString() : "",
    );
    descC = TextEditingController(text: widget.menu?.description ?? "");
    _currentImageUrl = widget.menu?.image;
  }

  void _initializeIngredients() {
    if (isEdit && widget.menu != null) {
      ingredients = widget.menu!.ingredients.map((e) {
        return IngredientFormModel(
          ingredient: MasterIngredientModel(
            id: e.ingredient.id,
            name: e.ingredient.name,
            unitId: e.unit.id,
            unitName: e.unit.name,
          ),
          quantity: e.quantity,
          unit: MasterUnitModel(id: e.unit.id, name: e.unit.name),
        );
      }).toList();
    }
  }

  // ==================== DATA LOADING ====================

  Future<void> _loadMasterData() async {
    try {
      final loadedIngredients = await IngredientService.getIngredients();
      final loadedUnits = await UnitService.getUnits();

      setState(() {
        masterIngredients = loadedIngredients
            .map(
              (e) => MasterIngredientModel(
                id: e.id,
                name: e.name,
                unitId: e.unitId, // Get unit_id from ingredient
                unitName: e.unitName, // Get unit_name from ingredient
              ),
            )
            .toList();
        masterUnits = loadedUnits
            .map((e) => MasterUnitModel(id: e.id, name: e.name))
            .toList();
        isMasterLoading = false;
      });
    } catch (e) {
      setState(() => isMasterLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal memuat data master: $e")));
      }
    }
  }

  // ==================== ACTIONS ====================

  void addIngredient() {
    setState(() {
      ingredients.add(IngredientFormModel());
    });
  }

  void removeIngredient(int index) {
    setState(() {
      ingredients.removeAt(index);
    });
  }

  void onIngredientChanged(
    int index,
    MasterIngredientModel? selectedIngredient,
  ) {
    setState(() {
      ingredients[index].ingredient = selectedIngredient;

      // Auto-fill unit from ingredient
      if (selectedIngredient != null && selectedIngredient.unitId != null) {
        final unit = masterUnits.firstWhere(
          (u) => u.id == selectedIngredient.unitId,
          orElse: () => MasterUnitModel(
            id: selectedIngredient.unitId!,
            name: selectedIngredient.unitName ?? '',
          ),
        );
        ingredients[index].unit = unit;
      } else {
        ingredients[index].unit = null;
      }
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  // ==================== FORM SUBMISSION ====================

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (ingredients.isEmpty) {
      _showSnackBar("Minimal satu ingredient harus ditambahkan");
      return;
    }

    if (ingredients.any(
      (i) => i.ingredient == null || i.unit == null || i.quantity <= 0,
    )) {
      _showSnackBar("Pastikan semua Ingredient dan Quantity sudah diisi");
      return;
    }

    // Validasi gambar untuk create
    if (!isEdit && _imageFile == null) {
      _showSnackBar("Gambar menu wajib dipilih");
      return;
    }

    setState(() => isLoading = true);

    try {
      final ingredientsData = ingredients.map((e) => e.toJson()).toList();

      if (isEdit) {
        // UPDATE MENU - Always use multipart for consistency
        await MenuService.updateMenuWithFile(
          id: widget.menu!.id,
          name: nameC.text,
          imageFile: _imageFile != null ? File(_imageFile!.path) : null,
          price: double.parse(priceC.text),
          description: descC.text,
          ingredients: ingredientsData,
        );
      } else {
        // CREATE MENU
        await MenuService.createMenuWithFile(
          name: nameC.text,
          imageFile: File(_imageFile!.path),
          price: double.parse(priceC.text),
          description: descC.text,
          ingredients: ingredientsData,
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showSnackBar("Gagal menyimpan menu: ${e.toString()}");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  // ==================== BUILD UI ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Menu" : "Tambah Menu"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isMasterLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(defaultPadding),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInfo(),
            const SizedBox(height: fieldSpacing * 1.5),
            _buildIngredientsSection(),
            const SizedBox(height: 30),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      children: [
        _buildTextField(
          controller: nameC,
          label: "Nama Menu",
          icon: Icons.fastfood_outlined,
        ),
        _buildImageUploadWidget(),
        _buildTextField(
          controller: priceC,
          label: "Harga",
          icon: Icons.attach_money,
          isNumber: true,
        ),
        _buildTextField(
          controller: descC,
          label: "Deskripsi",
          icon: Icons.description_outlined,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildIngredientsSection() {
    return Column(
      children: [
        _buildIngredientsHeader(),
        const Divider(height: 1, color: Colors.grey),
        const SizedBox(height: fieldSpacing / 2),
        _buildIngredientsList(),
      ],
    );
  }

  Widget _buildIngredientsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Daftar Bahan Baku (Ingredients)",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Tooltip(
            message: "Tambah Ingredient",
            child: IconButton(
              icon: const Icon(Icons.add_circle, color: primaryColor, size: 30),
              onPressed: addIngredient,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsList() {
    if (ingredients.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            "Tekan '+' untuk menambahkan bahan.",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: ingredients.asMap().entries.map((entry) {
        return _buildIngredientCard(entry.key, entry.value);
      }).toList(),
    );
  }

  // ==================== WIDGET BUILDERS ====================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: fieldSpacing),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (v) => v == null || v.isEmpty ? "$label wajib diisi" : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadWidget() {
    return Padding(
      padding: const EdgeInsets.only(bottom: fieldSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Gambar Menu",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          _buildImagePreview(),
          const SizedBox(height: 10),
          _buildUploadButton(),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(10),
      ),
      child: _getImageWidget(),
    );
  }

  Widget _getImageWidget() {
    // Prioritas: file baru yang dipilih > URL dari server > placeholder
    if (_imageFile != null) {
      return _buildLocalImage(_imageFile!.path);
    }

    if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
      return _buildNetworkImage(_currentImageUrl!);
    }

    return _buildPlaceholder();
  }

  Widget _buildLocalImage(String path) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            File(path),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Icon(
                Icons.broken_image,
                size: 50,
                color: Colors.redAccent,
              ),
            ),
          ),
          const Positioned(
            bottom: 4,
            right: 4,
            child: Icon(Icons.check_circle, color: Colors.green, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkImage(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(color: primaryColor),
          );
        },
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(
            Icons.image_not_supported,
            size: 50,
            color: Colors.redAccent,
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image, size: 40, color: Colors.grey),
          Text("Pilih Gambar Menu", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildUploadButton() {
    return ElevatedButton.icon(
      onPressed: _pickImage,
      icon: const Icon(Icons.cloud_upload_outlined, color: Colors.white),
      label: Text(
        _imageFile != null ? "Ganti Gambar" : "Upload Gambar",
        style: const TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildIngredientCard(int index, IngredientFormModel item) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: fieldSpacing),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            _buildIngredientCardHeader(index),
            const Divider(),
            _buildIngredientDropdown(index, item),
            _buildQuantityInput(index, item),
            _buildUnitDisplay(index, item), // Changed to display only
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientCardHeader(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Bahan #${index + 1}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        Tooltip(
          message: "Hapus Ingredient",
          child: IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            onPressed: () => removeIngredient(index),
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientDropdown(int index, IngredientFormModel item) {
    return _buildDropdown<MasterIngredientModel>(
      label: "Bahan Baku",
      value: item.ingredient,
      items: masterIngredients,
      onChanged: (value) => onIngredientChanged(index, value),
      itemBuilder: (i) => i.name,
      icon: Icons.kitchen,
    );
  }

  Widget _buildQuantityInput(int index, IngredientFormModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: fieldSpacing / 2),
      child: TextFormField(
        initialValue: item.quantity > 0 ? item.quantity.toString() : "",
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: "Jumlah",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return "Jumlah wajib diisi";
          if (double.tryParse(v) == null) return "Jumlah harus angka";
          if (double.parse(v) <= 0) return "Jumlah harus lebih dari 0";
          return null;
        },
        onChanged: (v) {
          ingredients[index].quantity = double.tryParse(v) ?? 0.0;
        },
      ),
    );
  }

  Widget _buildUnitDisplay(int index, IngredientFormModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: fieldSpacing / 2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.straighten, color: Colors.grey[600], size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Satuan",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.unit?.name ?? "Pilih bahan terlebih dahulu",
                    style: TextStyle(
                      fontSize: 16,
                      color: item.unit != null
                          ? Colors.black87
                          : Colors.grey[400],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (item.unit != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green[700],
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Auto",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
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

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required Function(T?) onChanged,
    required String Function(T) itemBuilder,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: fieldSpacing / 2),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 15,
          ),
        ),
        isExpanded: true,
        validator: (v) => v == null ? "$label wajib dipilih" : null,
        items: items.map<DropdownMenuItem<T>>((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(itemBuilder(item)),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: isLoading ? null : submit,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
      ),
      child: Text(
        isLoading ? "Menyimpan..." : "Simpan Menu",
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
