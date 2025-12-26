// lib/features/transaction/data/services/transaction_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ingredient_management_app/features/transaction/data/models/transaction_model.dart';

class TransactionService {
  // Sesuaikan dengan URL API Anda
  static const String baseUrl = "http://alope.site:8080";

  // static Future<List<TransactionModel>> fetchTodayTransactions() async {
  //   final response = await http.get(Uri.parse('$baseUrl/transactions/'));

  //   if (response.statusCode == 200) {
  //     final Map<String, dynamic> jsonResponse = json.decode(response.body);
  //     final List<dynamic> data = jsonResponse['data'];

  //     // Filter transaksi hari ini
  //     final today = DateTime.now();
  //     final todayTransactions = data.where((json) {
  //       final transactionDate = DateTime.parse(json['transaction_date']);
  //       return transactionDate.year == today.year &&
  //           transactionDate.month == today.month &&
  //           transactionDate.day == today.day;
  //     }).toList();

  //     return todayTransactions
  //         .map((json) => TransactionModel.fromJson(json))
  //         .toList();
  //   } else {
  //     throw Exception('Failed to load transactions');
  //   }
  // }

  static Future<List<TransactionModel>> fetchTransactions({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    String url = "$baseUrl/transactions";

    if (startDate != null && endDate != null) {
      final s = startDate.toIso8601String().split('T').first;
      final e = endDate.toIso8601String().split('T').first;
      url += "?start_date=$s&end_date=$e";
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return (decoded['data'] as List)
          .map((e) => TransactionModel.fromJson(e))
          .toList();
    } else {
      throw Exception("Failed to fetch transactions");
    }
  }

  /// default: hari ini
  static Future<List<TransactionModel>> fetchTodayTransactions() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    return fetchTransactions(startDate: start, endDate: end);
  }

  /// Fetch transaction by ID
  static Future<TransactionModel> fetchTransactionById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/transactions/$id'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return TransactionModel.fromJson(jsonResponse['data']);
    } else {
      throw Exception('Failed to load transaction');
    }
  }

  /// Create transaction
  static Future<Map<String, dynamic>> createTransaction({
    required List<Map<String, dynamic>> items,
    String notes = '',
  }) async {
    try {
      print('=== REQUEST ===');
      // TAMBAHKAN TRAILING SLASH di sini
      print('URL: $baseUrl/transactions/');
      print('Body: ${json.encode({'items': items, 'notes': notes})}');

      final response = await http.post(
        Uri.parse('$baseUrl/transactions/'), // <-- Tambahkan /
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'items': items, 'notes': notes}),
      );

      print('=== RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.body.isEmpty) {
        throw Exception('Server mengembalikan response kosong');
      }

      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (response.statusCode == 201) {
        return jsonResponse['data'];
      } else {
        throw Exception(
          jsonResponse['message'] ?? 'Failed to create transaction',
        );
      }
    } catch (e) {
      print('=== ERROR ===');
      print('Error: $e');
      rethrow;
    }
  }

  /// Delete transaction
  static Future<void> deleteTransaction(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/transactions/$id'));

    if (response.statusCode != 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      throw Exception(
        jsonResponse['message'] ?? 'Failed to delete transaction',
      );
    }
  }
}
