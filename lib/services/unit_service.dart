import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/unit_model.dart';

class UnitService {
  static const String baseUrl = "http://localhost:8080";

  static Future<List<UnitModel>> getUnits() async {
    final response = await http.get(Uri.parse("$baseUrl/units/"));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return (body['data'] as List).map((e) => UnitModel.fromJson(e)).toList();
    } else {
      throw Exception("Gagal mengambil unit");
    }
  }
}
