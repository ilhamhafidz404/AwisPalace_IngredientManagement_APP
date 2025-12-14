class IngredientModel {
  final int id;
  final String name;
  final String slug;
  final int stock;
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
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      stock: json['stock'],
      unitId: json['unit_id'],
      unitName: json['unit']['name'],
      unitSymbol: json['unit']['symbol'],
    );
  }

  Map<String, dynamic> toJson() {
    return {"name": name, "stock": stock, "unit_id": unitId};
  }
}
