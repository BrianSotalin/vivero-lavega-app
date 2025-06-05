class OrderItem {
  final String id;
  final String orderId;
  final String plantId;
  final int quantity;
  final double priceAtSale;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.plantId,
    required this.quantity,
    required this.priceAtSale,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      orderId: json['order_id'],
      plantId: json['plant_id'],
      quantity: json['quantity'],
      priceAtSale: double.parse(json['price_at_sale'].toString()),
    );
  }
  OrderItem copyWith({int? quantity, double? priceAtSale, String? plantId}) {
    return OrderItem(
      id: id,
      orderId: orderId,
      plantId: plantId ?? this.plantId,
      quantity: quantity ?? this.quantity,
      priceAtSale: priceAtSale ?? this.priceAtSale,
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'order_id': orderId,
      'plant_id': plantId,
      'quantity': quantity,
      'price_at_sale': priceAtSale,
    };
    if (id.isEmpty) {
      map['id'] = id;
    }
    return map;
  }


}
