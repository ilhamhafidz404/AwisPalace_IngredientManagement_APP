import 'package:ingredient_management_app/models/menu_ingredient_model.dart';

class MenuModel {
  final int id;
  final String name;
  final String slug;
  final String image;
  final double price;
  final String description;
  final List<MenuIngredientModel> ingredients;

  MenuModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.image,
    required this.price,
    required this.description,
    required this.ingredients,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      description: json['description']?.toString() ?? '',
      ingredients: (json['ingredients'] as List? ?? [])
          .map((e) => MenuIngredientModel.fromJson(e))
          .toList(),
    );
  }
}

//
class MenuCreatePayload {
  final String name;
  final String description;
  final String image;
  final double price;
  final List<Map<String, dynamic>>
  ingredients; // List map dari IngredientFormModel.toJson()

  MenuCreatePayload({
    required this.name,
    required this.description,
    required this.image,
    required this.price,
    required this.ingredients,
  });

  Map<String, dynamic> toJson() => {
    "name": name,
    "description": description,
    "image": image,
    "price": price,
    "ingredients": ingredients,
  };
}
