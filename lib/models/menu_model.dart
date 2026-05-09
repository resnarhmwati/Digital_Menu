class MenuModel {
  final String id;
  final String cafeId;
  final String categoryId;
  final String name;
  final String description;
  final int price;
  final String imageUrl;
  final bool isAvailable;

  MenuModel({
    required this.id,
    required this.cafeId,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.isAvailable,
  });

  factory MenuModel.fromFirestore(Map<String, dynamic> data, String id) {
    return MenuModel(
      id: id,
      cafeId: data['cafe_id'] ?? '',
      categoryId: data['category_id'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: data['price'] ?? 0,
      imageUrl: data['image_url'] ?? '',
      isAvailable: data['is_available'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'cafe_id': cafeId,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'is_available': isAvailable,
    };
  }
}