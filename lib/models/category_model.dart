class CategoryModel {
  final String id;
  final String cafeId;
  final String name;
  final int order;
  final bool isActive;

  CategoryModel({
    required this.id,
    required this.cafeId,
    required this.name,
    required this.order,
    required this.isActive,
  });

  factory CategoryModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CategoryModel(
      id: id,
      cafeId: data['cafe_id'] ?? '',
      name: data['name'] ?? '',
      order: data['order'] ?? 0,
      isActive: data['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'cafe_id': cafeId,
      'name': name,
      'order': order,
      'is_active': isActive,
    };
  }
}