import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// --- IMPORT SERVICE ASLI ---
// Pastikan service-service ini diimpor:
import 'package:ingredient_management_app/features/ingredient/data/services/ingredient_service.dart';
import 'package:ingredient_management_app/services/unit_service.dart';
import '../../data/services/menu_service.dart';
import '../../data/models/menu_model.dart'; // Mengandung MenuModel dan MenuIngredientModel

class MasterIngredientModel {
  final int id;
  final String name;
  MasterIngredientModel({required this.id, required this.name});
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MasterIngredientModel &&
          runtimeType == other.runtimeType &&
          id == other.id;
  @override
  int get hashCode => id.hashCode;
}

// Ini mungkin adalah model asli yang dikembalikan oleh UnitService.getUnits()
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

// Ini adalah model form yang harus disesuaikan dengan MasterModel di atas
class IngredientFormModel {
  MasterIngredientModel? ingredient; // Diubah ke MasterIngredientModel
  double quantity;
  MasterUnitModel? unit; // Diubah ke MasterUnitModel

  IngredientFormModel({this.ingredient, this.quantity = 0.0, this.unit});

  Map<String, dynamic> toJson() => {
    "ingredient_id": ingredient?.id ?? 0,
    "quantity": quantity,
    "unit_id": unit?.id ?? 0,
  };
}
// End Penyesuaian Model

// Konstanta Styling
const Color primaryColor = Color(0xff00C3FF);
const double defaultPadding = 16.0;
const double fieldSpacing = 16.0;

class MenuFormPage extends StatefulWidget {
  final MenuModel? menu;

  const MenuFormPage({super.key, this.menu});

  @override
  State<MenuFormPage> createState() => _MenuFormPageState();
}

class _MenuFormPageState extends State<MenuFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameC;
  late TextEditingController priceC;
  late TextEditingController descC;

  String? _currentImageUrl;
  XFile? _imageFile;

  /// LIST INGREDIENT DINAMIS (Dipertahankan)
  List<IngredientFormModel> ingredients = [];

  // Data Master untuk Dropdown (Diubah typenya sesuai model yang digunakan untuk form)
  List<MasterIngredientModel> masterIngredients = [];
  List<MasterUnitModel> masterUnits = [];

  bool isLoading = false;
  bool isMasterLoading = true;

  bool get isEdit => widget.menu != null;

  @override
  void initState() {
    super.initState();

    _loadMasterData(); // Panggil fungsi load data master

    nameC = TextEditingController(text: widget.menu?.name ?? "");
    _currentImageUrl = widget.menu?.image;
    priceC = TextEditingController(
      text: widget.menu != null ? widget.menu!.price.toString() : "",
    );
    descC = TextEditingController(text: widget.menu?.description ?? "");

    if (isEdit) {
      // Perbaiki inisialisasi ingredients agar mengambil data dari MenuModel
      ingredients = widget.menu!.ingredients.map((e) {
        // e adalah MenuIngredientModel, yang berisi e.ingredient (IngredientForMenuModel)
        // dan e.unit (UnitForModel). Kita harus memetakannya ke MasterModel.

        // PERHATIAN: Bagian ini bergantung pada bagaimana Anda memetakan model
        // relasi (IngredientForMenuModel) ke model master (MasterIngredientModel).
        // Saya akan membuat MasterModel sederhana untuk inisialisasi:

        final MasterIngredientModel? ingredient = MasterIngredientModel(
          id: e
              .ingredient
              .id, // Asumsi e.ingredient adalah IngredientForMenuModel
          name: e.ingredient.name,
        );

        final MasterUnitModel? unit = MasterUnitModel(
          id: e.unit.id, // Asumsi e.unit adalah UnitForModel
          name: e.unit.name,
        );

        return IngredientFormModel(
          ingredient: ingredient,
          quantity: e.quantity,
          unit: unit,
        );
      }).toList();
    }
  }

  // (Di dalam _MenuFormPageState)

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;
    // Periksa apakah semua ingredient sudah terisi
    if (ingredients.any(
      (i) => i.ingredient == null || i.unit == null || i.quantity <= 0,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pastikan semua Ingredient dan Quantity sudah diisi"),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    // 1. Siapkan data ingredients dalam format yang benar (sudah ada di IngredientFormModel.toJson)
    final ingredientsData = ingredients.map((e) => e.toJson()).toList();

    // 2. Tentukan Image Path/URL yang akan dikirim
    // CATATAN PENTING: API Go Anda saat ini hanya menerima string (Image string/URL).
    // Jika Anda ingin upload file, Anda harus memodifikasi API Go Anda menjadi multipart/form-data.
    // Untuk saat ini, kita ikuti struktur API Anda yang hanya menerima string.
    final imageString = _currentImageUrl ?? _imageFile?.path ?? "";

    try {
      if (isEdit) {
        // LOGIC UNTUK EDIT/UPDATE MENU
        // Anda harus memanggil updateMenu di sini.
        final imagePathOrUrl = _imageFile?.path ?? _currentImageUrl;
        await MenuService.updateMenu(
          id: widget.menu!.id,
          name: nameC.text,
          // image: imagePathOrUrl, // Ganti imageFilePath menjadi image string
          image: imageString,
          price: double.parse(priceC.text),
          description: descC.text,
          ingredients: ingredientsData,
        );
      } else {
        // LOGIC UNTUK CREATE MENU BARU
        await MenuService.createMenu(
          name: nameC.text,
          image: imageString, // Menggunakan string yang sudah ditentukan
          price: double.parse(priceC.text),
          description: descC.text,
          ingredients: ingredientsData,
        );
      }

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan menu: ${e.toString()}")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// ================= FUNGSI (Memperbaiki error di _loadMasterData) =================
  Future<void> _loadMasterData() async {
    // NOTE: masterIngredients dan masterUnits di-declare sebagai List<IngredientModel>
    // dan List<UnitModel> di luar fungsi ini.

    // Asumsi: Service mengembalikan List<IngredientModel> dan List<UnitModel>
    // yang setara dengan MasterIngredientModel dan MasterUnitModel di sini.
    // Jika masih terjadi type error, ganti IngredientModel/UnitModel di service
    // dengan MasterIngredientModel/MasterUnitModel.

    try {
      // PANGGIL SERVICE (menggunakan type yang dikembalikan oleh service)
      final loadedIngredients = await IngredientService.getIngredients();
      final loadedUnits = await UnitService.getUnits();

      // ASSIGNMENT KE STATE (masterIngredients dan masterUnits)
      // Karena type di sini sudah diubah menjadi MasterIngredientModel dan MasterUnitModel,
      // ASUMSIKAN service mengembalikan type yang sama.
      setState(() {
        // HATI-HATI: Jangan menggunakan `List<IngredientModel> masterIngredients`
        // di dalam try block, karena akan membuat variabel lokal baru yang
        // menaungi variabel state. Gunakan assignment langsung ke variabel state.

        // Catatan: Jika service mengembalikan type yang berbeda, Anda harus
        // melakukan mapping, e.g., loadedIngredients.map((i) => MasterIngredientModel.fromService(i)).toList();

        // PENGGANTIAN VARIABEL DI FUNGSI ANDA UNTUK MENGHILANGKAN TYPE CONFLICT
        // Saya asumsikan loadedIngredients (dari service) adalah type yang sama
        // dengan MasterIngredientModel (yang digunakan di state).
        masterIngredients = loadedIngredients
            .map((e) => MasterIngredientModel(id: e.id, name: e.name))
            .toList();
        masterUnits = loadedUnits
            .map((e) => MasterUnitModel(id: e.id, name: e.name))
            .toList();
        isMasterLoading = false;
      });
    } catch (e) {
      // Pastikan variabel state isMasterLoading diakses dan diubah:
      setState(() => isMasterLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal memuat data master: $e")));
    }
  }

  void addIngredient() {
    setState(() {
      ingredients.add(IngredientFormModel());
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

  // Future<void> submit() async {
  //   if (!_formKey.currentState!.validate()) return;
  //   if (ingredients.any((i) => i.ingredient == null || i.unit == null)) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Semua Ingredient harus dipilih")),
  //     );
  //     return;
  //   }

  //   setState(() => isLoading = true);

  //   final ingredientsData = ingredients.map((e) => e.toJson()).toList();

  //   try {
  //     // ... Logika submit (tidak diubah)

  //     Navigator.pop(context, true);
  //   } catch (e) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text(e.toString())));
  //   } finally {
  //     setState(() => isLoading = false);
  //   }
  // }

  /// ================= UI/TAMPILAN (Tidak diubah, hanya memastikan widget helper berfungsi) =================
  @override
  Widget build(BuildContext context) {
    // ... (kode build method tetap sama)
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Menu" : "Tambah Menu"),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: isMasterLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(defaultPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Input Utama
                    _input(nameC, "Nama Menu", icon: Icons.fastfood_outlined),
                    _imageUploadWidget(),
                    _input(
                      priceC,
                      "Harga",
                      isNumber: true,
                      icon: Icons.attach_money,
                    ),
                    _input(
                      descC,
                      "Deskripsi",
                      maxLines: 3,
                      icon: Icons.description_outlined,
                    ),

                    const SizedBox(height: fieldSpacing * 1.5),

                    // HEADER INGREDIENTS
                    Padding(
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
                              icon: const Icon(
                                Icons.add_circle,
                                color: primaryColor,
                                size: 30,
                              ),
                              onPressed: addIngredient,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Colors.grey),
                    const SizedBox(height: fieldSpacing / 2),

                    /// LIST INGREDIENTS DENGAN TAMPILAN BARU
                    if (ingredients.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            "Tekan '+' untuk menambahkan bahan.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),

                    ...ingredients.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;

                      return _ingredientCard(index, item);
                    }).toList(),

                    const SizedBox(height: 30),

                    // TOMBOL SIMPAN
                    ElevatedButton(
                      onPressed: isLoading ? null : submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // ... (Widget Helper _input, _imageUploadWidget, _dropdownInput, _numberInput, _ingredientCard tetap sama,
  // tetapi kini menggunakan MasterIngredientModel dan MasterUnitModel)

  // Widget Dropdown Reusable yang diperbarui
  Widget _dropdownInput<T>({
    required String label,
    required T? value,
    required List<T> items,
    required Function(T?) onChanged,
    required String Function(T) itemBuilder,
    required IconData icon,
  }) {
    // ... (Implementation tetap sama)
    return Padding(
      padding: const EdgeInsets.only(bottom: fieldSpacing / 2),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          // prefixIcon: Icon(icon, color: primaryColor),
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

  // Widget Card Ingredient yang diperbarui
  Widget _ingredientCard(int index, IngredientFormModel item) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: fieldSpacing),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            // Header Ingredient Card
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Bahan #$index",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                Tooltip(
                  message: "Hapus Ingredient",
                  child: IconButton(
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    onPressed: () =>
                        setState(() => ingredients.removeAt(index)),
                  ),
                ),
              ],
            ),
            const Divider(),

            // Dropdown untuk Ingredient
            _dropdownInput<MasterIngredientModel>(
                  label: "Bahan Baku",
                  value: item.ingredient,
                  items: masterIngredients,
                  onChanged: (MasterIngredientModel? newValue) {
                    setState(() => ingredients[index].ingredient = newValue);
                  },
                  itemBuilder: (i) => i.name,
                  icon: Icons.kitchen,
                )
                as Widget, // Casting diperlukan karena T di _dropdownInput tidak diketahui
            // Input Quantity
            _numberInput(
              "Jumlah",
              item.quantity.toString(),
              (v) => ingredients[index].quantity = double.tryParse(v) ?? 0.0,
            ),

            // Dropdown untuk Unit
            _dropdownInput<MasterUnitModel>(
                  label: "Satuan",
                  value: item.unit,
                  items: masterUnits,
                  onChanged: (MasterUnitModel? newValue) {
                    setState(() => ingredients[index].unit = newValue);
                  },
                  itemBuilder: (u) => u.name,
                  icon: Icons.straighten,
                )
                as Widget, // Casting diperlukan
          ],
        ),
      ),
    );
  }

  // (Widget helper lainnya)
  Widget _input(
    TextEditingController c,
    String label, {
    bool isNumber = false,
    int maxLines = 1,
    IconData? icon,
  }) {
    /* ... */
    return Padding(
      padding: const EdgeInsets.only(bottom: fieldSpacing),
      child: TextFormField(
        controller: c,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (v) => v == null || v.isEmpty ? "$label wajib diisi" : null,
        decoration: InputDecoration(
          labelText: label,
          // prefixIcon: icon != null ? Icon(icon, color: primaryColor) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _imageUploadWidget() {
    /* ... */
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
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: _imageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          _imageFile!.path,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.insert_drive_file,
                                size: 50,
                                color: Colors.lightGreen,
                              ),
                          fit: BoxFit.cover,
                        ),
                        const Positioned(
                          bottom: 4,
                          right: 4,
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  )
                : _currentImageUrl != null && _currentImageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _currentImageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(color: primaryColor),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.redAccent,
                            ),
                          ),
                    ),
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image, size: 40, color: Colors.grey),
                        Text(
                          "Pilih Gambar Menu",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.cloud_upload_outlined, color: Colors.white),
            label: Text(
              _imageFile != null ? "Ganti Gambar" : "Upload Gambar",
              style: const TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _numberInput(String label, String value, Function(String) onChanged) {
    /* ... */
    return Padding(
      padding: const EdgeInsets.only(bottom: fieldSpacing / 2),
      child: TextFormField(
        initialValue: value,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          // prefixIcon: const Icon(Icons.numbers, color: primaryColor),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return "$label wajib diisi";
          if (double.tryParse(v) == null) return "$label harus angka";
          return null;
        },
        onChanged: onChanged,
      ),
    );
  }
}
