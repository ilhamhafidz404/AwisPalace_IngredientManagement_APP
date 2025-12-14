class UnitModel {
  final int id;
  final String name;
  final String symbol;

  UnitModel({required this.id, required this.name, required this.symbol});

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id'],
      name: json['name'],
      symbol: json['symbol'],
    );
  }
}
