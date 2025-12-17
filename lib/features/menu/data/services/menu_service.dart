import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/menu_model.dart';

class MenuService {
  static const String baseUrl = "http://alope.site:8080";

  // ==================== FETCH METHODS ====================

  /// Get all menus
  static Future<List<MenuModel>> fetchMenus() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/menus/"));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List data = decoded['data'] ?? [];
        return data.map((e) => MenuModel.fromJson(e)).toList();
      } else {
        throw _handleError(response, "Failed to load menus");
      }
    } catch (e) {
      throw Exception("Error fetching menus: $e");
    }
  }

  /// Get menu by ID
  static Future<MenuModel> fetchMenuById(int id) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/menus/$id"));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return MenuModel.fromJson(decoded['data']);
      } else {
        throw _handleError(response, "Failed to load menu detail");
      }
    } catch (e) {
      throw Exception("Error fetching menu detail: $e");
    }
  }

  // ==================== CREATE METHOD ====================

  /// Create new menu with image file (REQUIRED)
  static Future<void> createMenuWithFile({
    required String name,
    required File imageFile,
    required double price,
    required String description,
    required List<Map<String, dynamic>> ingredients,
  }) async {
    try {
      final uri = Uri.parse("$baseUrl/menus");
      var request = http.MultipartRequest('POST', uri);

      // Add text fields
      request.fields['name'] = name;
      request.fields['price'] = price.toString();
      request.fields['description'] = description;
      request.fields['ingredients'] = jsonEncode(ingredients);

      // Add image file
      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var multipartFile = http.MultipartFile(
        'image',
        stream,
        length,
        filename: imageFile.path.split('/').last,
      );
      request.files.add(multipartFile);

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 201) {
        throw _handleError(response, "Failed to create menu");
      }
    } catch (e) {
      throw Exception("Error creating menu: $e");
    }
  }

  // ==================== UPDATE METHOD ====================

  /// Update existing menu (image file is OPTIONAL)
  static Future<void> updateMenuWithFile({
    required int id,
    required String name,
    File? imageFile, // Nullable - jika null, gambar tidak diubah
    required double price,
    required String description,
    required List<Map<String, dynamic>> ingredients,
  }) async {
    try {
      final uri = Uri.parse("$baseUrl/menus/$id");
      var request = http.MultipartRequest('PUT', uri);

      // Add text fields
      request.fields['name'] = name;
      request.fields['price'] = price.toString();
      request.fields['description'] = description;
      request.fields['ingredients'] = jsonEncode(ingredients);

      // Add image file only if provided (optional for update)
      if (imageFile != null) {
        var stream = http.ByteStream(imageFile.openRead());
        var length = await imageFile.length();
        var multipartFile = http.MultipartFile(
          'image',
          stream,
          length,
          filename: imageFile.path.split('/').last,
        );
        request.files.add(multipartFile);
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        throw _handleError(response, "Failed to update menu");
      }
    } catch (e) {
      throw Exception("Error updating menu: $e");
    }
  }

  // ==================== DELETE METHOD ====================

  /// Delete menu by ID
  static Future<void> deleteMenu(int id) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl/menus/$id"));

      if (response.statusCode != 200) {
        throw _handleError(response, "Failed to delete menu");
      }
    } catch (e) {
      throw Exception("Error deleting menu: $e");
    }
  }

  // ==================== HELPER METHODS ====================

  /// Handle error response from API
  static Exception _handleError(http.Response response, String defaultMessage) {
    try {
      final errorBody = jsonDecode(response.body);
      final message = errorBody['message'] ?? defaultMessage;
      return Exception("$message (Status: ${response.statusCode})");
    } catch (_) {
      return Exception("$defaultMessage (Status: ${response.statusCode})");
    }
  }
}
