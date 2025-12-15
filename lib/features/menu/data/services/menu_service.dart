import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/menu_model.dart';

class MenuService {
  static const String baseUrl = "http://alope.site:8080";

  /// =========================
  /// GET ALL MENUS
  /// =========================
  static Future<List<MenuModel>> fetchMenus() async {
    final response = await http.get(Uri.parse("$baseUrl/menus/"));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List data = decoded['data'];

      return data.map((e) => MenuModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load menus");
    }
  }

  /// =========================
  /// GET MENU BY ID
  /// =========================
  static Future<MenuModel> fetchMenuById(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/menus/$id"));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return MenuModel.fromJson(decoded['data']);
    } else {
      throw Exception("Failed to load menu detail");
    }
  }

  /// =========================
  /// CREATE MENU
  /// =========================
  static Future<void> createMenu({
    required String name,
    required String image,
    required double price,
    required String description,
    required List<Map<String, dynamic>> ingredients,
  }) async {
    final url = Uri.parse("$baseUrl/menus");

    // Buat Payload
    final payload = MenuCreatePayload(
      name: name,
      description: description,
      image: image,
      price: price,
      ingredients: ingredients,
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload.toJson()), // Mengirim data sebagai JSON
      );

      if (response.statusCode == 201) {
        // HTTP Status 201 Created (sesuai API Go Anda)
        return;
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          "Gagal membuat menu: ${errorBody['message'] ?? response.reasonPhrase}",
        );
      }
    } catch (e) {
      throw Exception("Kesalahan koneksi saat membuat menu: $e");
    }
  }

  /// =========================
  /// UPDATE MENU
  /// =========================
  static Future<void> updateMenu({
    required int id,
    required String name,
    required String image,
    required double price,
    String? description,
    required List<Map<String, dynamic>> ingredients,
  }) async {
    final body = {
      "name": name,
      "image": image,
      "price": price,
      "description": description,
      "ingredients": ingredients,
    };

    final response = await http.put(
      Uri.parse("$baseUrl/menus/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update menu");
    }
  }

  /// =========================
  /// DELETE MENU
  /// =========================
  static Future<void> deleteMenu(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/menus/$id"));

    if (response.statusCode != 200) {
      throw Exception("Failed to delete menu");
    }
  }
}
