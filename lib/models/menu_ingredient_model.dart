class MenuIngredientModel {
  final int id;
  final IngredientForMenuModel ingredient;
  final double quantity;
  final UnitForModel unit;

  MenuIngredientModel({
    required this.id,
    required this.ingredient,
    required this.quantity,
    required this.unit,
  });

  factory MenuIngredientModel.fromJson(Map<String, dynamic> json) {
    return MenuIngredientModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      ingredient: IngredientForMenuModel.fromJson(json['ingredient'] ?? {}),
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      unit: UnitForModel.fromJson(json['unit'] ?? {}),
    );
  }
}

class IngredientForMenuModel {
  final int id;
  final String name;
  final String slug;

  IngredientForMenuModel({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory IngredientForMenuModel.fromJson(Map<String, dynamic> json) {
    return IngredientForMenuModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
    );
  }
}

class UnitForModel {
  final int id;
  final String name;

  UnitForModel({required this.id, required this.name});

  factory UnitForModel.fromJson(Map<String, dynamic> json) {
    return UnitForModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}
