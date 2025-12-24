import 'package:intl/intl.dart';

extension RupiahFormat on num {
  String toRupiah({bool withSymbol = true}) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: withSymbol ? 'Rp ' : '',
      decimalDigits: 0,
    );
    return formatter.format(this);
  }
}
