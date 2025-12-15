// lib/features/transaction/data/models/transaction_model.dart

class TransactionModel {
  final int id;
  final String transactionCode;
  final DateTime transactionDate;
  final double totalAmount;
  final String notes;
  final String status;
  final List<TransactionItemModel> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionModel({
    required this.id,
    required this.transactionCode,
    required this.transactionDate,
    required this.totalAmount,
    required this.notes,
    required this.status,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      transactionCode: json['transaction_code'],
      transactionDate: DateTime.parse(json['transaction_date']),
      totalAmount: (json['total_amount'] as num).toDouble(),
      notes: json['notes'] ?? '',
      status: json['status'],
      items: (json['items'] as List)
          .map((item) => TransactionItemModel.fromJson(item))
          .toList(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class TransactionItemModel {
  final int id;
  final TransactionItemMenuModel menu;
  final int quantity;
  final double price;
  final List<StockReductionModel> stockReductions; // TAMBAHKAN INI

  TransactionItemModel({
    required this.id,
    required this.menu,
    required this.quantity,
    required this.price,
    required this.stockReductions, // TAMBAHKAN INI
  });

  factory TransactionItemModel.fromJson(Map<String, dynamic> json) {
    return TransactionItemModel(
      id: json['id'],
      menu: TransactionItemMenuModel.fromJson(json['menu']),
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
      // TAMBAHKAN INI
      stockReductions: json['stock_reductions'] != null
          ? (json['stock_reductions'] as List)
                .map((sr) => StockReductionModel.fromJson(sr))
                .toList()
          : [],
    );
  }
}

class TransactionItemMenuModel {
  final int id;
  final String name;
  final String slug;
  final String image;

  TransactionItemMenuModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.image,
  });

  factory TransactionItemMenuModel.fromJson(Map<String, dynamic> json) {
    return TransactionItemMenuModel(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      image: json['image'] ?? '',
    );
  }
}

// TAMBAHKAN MODEL BARU INI
class StockReductionModel {
  final int id;
  final StockReductionIngredientModel ingredient;
  final double quantityReduced;
  final double stockBefore;
  final double stockAfter;
  final StockReductionUnitModel unit;

  StockReductionModel({
    required this.id,
    required this.ingredient,
    required this.quantityReduced,
    required this.stockBefore,
    required this.stockAfter,
    required this.unit,
  });

  factory StockReductionModel.fromJson(Map<String, dynamic> json) {
    return StockReductionModel(
      id: json['id'],
      ingredient: StockReductionIngredientModel.fromJson(json['ingredient']),
      quantityReduced: (json['quantity_reduced'] as num).toDouble(),
      stockBefore: (json['stock_before'] as num).toDouble(),
      stockAfter: (json['stock_after'] as num).toDouble(),
      unit: StockReductionUnitModel.fromJson(json['unit']),
    );
  }
}

class StockReductionIngredientModel {
  final int id;
  final String name;
  final String slug;

  StockReductionIngredientModel({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory StockReductionIngredientModel.fromJson(Map<String, dynamic> json) {
    return StockReductionIngredientModel(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
    );
  }
}

class StockReductionUnitModel {
  final int id;
  final String name;

  StockReductionUnitModel({required this.id, required this.name});

  factory StockReductionUnitModel.fromJson(Map<String, dynamic> json) {
    return StockReductionUnitModel(id: json['id'], name: json['name']);
  }
}
