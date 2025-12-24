import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ingredient_model.dart';

class IngredientService {
  static const String baseUrl = "http://localhost:8080";

  /// GET
  static Future<List<IngredientModel>> getIngredients() async {
    final response = await http.get(Uri.parse("$baseUrl/ingredients/"));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return (body['data'] as List)
          .map((e) => IngredientModel.fromJson(e))
          .toList();
    } else {
      throw Exception("Gagal mengambil data ingredient");
    }
  }

  /// POST
  static Future<void> createIngredient({
    required String name,
    required int stock,
    required int unitId,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/ingredients/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "stock": stock, "unit_id": unitId}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Gagal menambahkan ingredient");
    }
  }

  /// PUT
  static Future<void> updateIngredient({
    required int id,
    required String name,
    required int stock,
    required int unitId,
  }) async {
    final response = await http.put(
      Uri.parse("$baseUrl/ingredients/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "stock": stock, "unit_id": unitId}),
    );

    if (response.statusCode != 200) {
      throw Exception("Gagal update ingredient");
    }
  }

  /// DELETE
  static Future<void> deleteIngredient(int id) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/ingredients/$id"),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Delete gagal (${response.statusCode})");
    }
  }
}
