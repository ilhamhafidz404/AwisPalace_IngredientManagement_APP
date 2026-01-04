String formatStock(double stock) {
  if (stock % 1 == 0) {
    return stock.toInt().toString();
  }
  return stock.toStringAsFixed(1);
}
