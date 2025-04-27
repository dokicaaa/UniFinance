double convertCurrency(double amount, String from, String to) {
  if (from == to) return amount;
  final Map<String, double> rates = {
    'USD': 1.0,
    'EUR': 0.92,
    'MKD': 50.0,
  };
  double amountInUSD = amount / rates[from]!;
  double converted = amountInUSD * rates[to]!;
  return converted;
}
