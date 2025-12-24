import 'package:ingredient_management_app/features/transaction/data/services/transaction_service.dart';

class HomeService {
  static Future<Map<String, dynamic>> getDashboard({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final transactions = await TransactionService.fetchTransactions(
        startDate: startDate,
        endDate: endDate,
      );

      Map<String, Map<String, dynamic>> menuAggregation = {};
      Map<String, Map<String, dynamic>> ingredientAggregation = {};

      for (var transaction in transactions) {
        for (var item in transaction.items) {
          final menuKey = item.menu.id.toString();

          menuAggregation.update(
            menuKey,
            (v) {
              v['quantity'] += item.quantity;
              return v;
            },
            ifAbsent: () => {
              'id': item.menu.id,
              'name': item.menu.name,
              'image': item.menu.image,
              'quantity': item.quantity,
            },
          );

          for (var reduction in item.stockReductions) {
            final ingredientKey = reduction.ingredient.id.toString();

            ingredientAggregation.update(
              ingredientKey,
              (v) {
                v['quantity'] += reduction.quantityReduced;
                return v;
              },
              ifAbsent: () => {
                'id': reduction.ingredient.id,
                'name': reduction.ingredient.name,
                'quantity': reduction.quantityReduced,
                'unit': reduction.unit.name,
              },
            );
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

  /// shortcut hari ini
  static Future<Map<String, dynamic>> getTodayDashboard() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return getDashboard(startDate: start, endDate: end);
  }
}
