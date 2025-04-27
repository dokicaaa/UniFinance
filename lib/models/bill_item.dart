class BillItem {
  final String itemName;
  final double price;

  BillItem({required this.itemName, required this.price});

  factory BillItem.fromJson(Map<String, dynamic> json) {
    return BillItem(
      itemName: json['itemName'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'itemName': itemName, 'price': price};
  }
}
