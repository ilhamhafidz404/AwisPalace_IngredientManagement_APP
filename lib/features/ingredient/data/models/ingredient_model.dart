class IngredientModel {
  final int id;
  final String name;
  final String slug;
  final double stock;
  final int unitId;
  final String unitName;
  final String unitSymbol;

  IngredientModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.stock,
    required this.unitId,
    required this.unitName,
    required this.unitSymbol,
  });

  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    return IngredientModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      slug: json['slug'] ?? "",
      stock: _toDouble(json['stock']),
      unitId: json['unit_id'],
      unitName: json['unit']['name'],
      unitSymbol: json['unit']['symbol'],
    );
  }

  Map<String, dynamic> toJson() {
    return {"name": name, "stock": stock, "unit_id": unitId};
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
