// lib/features/home/data/services/home_service.dart

import 'package:ingredient_management_app/features/transaction/data/services/transaction_service.dart';

class HomeService {
  /// Get transaksi hari ini dengan agregasi menu
  static Future<Map<String, dynamic>> getTodayDashboard() async {
    try {
      final transactions = await TransactionService.fetchTodayTransactions();

      // Agregasi menu yang terjual
      Map<String, Map<String, dynamic>> menuAggregation = {};

      // Agregasi ingredient yang digunakan
      Map<String, Map<String, dynamic>> ingredientAggregation = {};

      for (var transaction in transactions) {
        for (var item in transaction.items) {
          final menuKey = item.menu.id.toString();

          // Agregasi menu
          if (menuAggregation.containsKey(menuKey)) {
            menuAggregation[menuKey]!['quantity'] += item.quantity;
          } else {
            menuAggregation[menuKey] = {
              'id': item.menu.id,
              'name': item.menu.name,
              'image': item.menu.image,
              'quantity': item.quantity,
            };
          }

          // Agregasi ingredients dari stock reductions
          for (var reduction in item.stockReductions) {
            final ingredientKey = reduction.ingredient.id.toString();

            if (ingredientAggregation.containsKey(ingredientKey)) {
              ingredientAggregation[ingredientKey]!['quantity'] +=
                  reduction.quantityReduced;
            } else {
              ingredientAggregation[ingredientKey] = {
                'id': reduction.ingredient.id,
                'name': reduction.ingredient.name,
                'quantity': reduction.quantityReduced,
                'unit': reduction.unit.name,
              };
            }
          }
        }
      }

      return {
        'menus': menuAggregation.values.toList(),
        'ingredients': ingredientAggregation.values.toList(),
        'total_transactions': transactions.length,
      };
    } catch (e) {
      throw Exception('Failed to load dashboard data: $e');
    }
  }
}
