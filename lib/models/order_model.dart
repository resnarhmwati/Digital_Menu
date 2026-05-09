class OrderItemModel {
  final String menuId;
  final String menuName;
  final int price;
  final int quantity;

  OrderItemModel({
    required this.menuId,
    required this.menuName,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'menu_id': menuId,
      'menu_name': menuName,
      'price': price,
      'quantity': quantity,
    };
  }

  factory OrderItemModel.fromFirestore(Map<String, dynamic> data) {
    return OrderItemModel(
      menuId: data['menu_id'] ?? '',
      menuName: data['menu_name'] ?? '',
      price: data['price'] ?? 0,
      quantity: data['quantity'] ?? 1,
    );
  }
}

class OrderModel {
  final String id;
  final String cafeId;
  final String tableNumber;
  final String status; // pending, diproses, selesai
  final int total;
  final DateTime createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.cafeId,
    required this.tableNumber,
    required this.status,
    required this.total,
    required this.createdAt,
    required this.items,
  });

  factory OrderModel.fromFirestore(Map<String, dynamic> data, String id) {
    return OrderModel(
      id: id,
      cafeId: data['cafe_id'] ?? '',
      tableNumber: data['table_number'] ?? '',
      status: data['status'] ?? 'pending',
      total: data['total'] ?? 0,
      createdAt: (data['created_at'])?.toDate() ?? DateTime.now(),
      items: (data['items'] as List<dynamic>? ?? [])
          .map((e) => OrderItemModel.fromFirestore(e))
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'cafe_id': cafeId,
      'table_number': tableNumber,
      'status': status,
      'total': total,
      'created_at': createdAt,
      'items': items.map((e) => e.toFirestore()).toList(),
    };
  }
}