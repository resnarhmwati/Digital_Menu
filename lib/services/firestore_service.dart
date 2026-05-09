import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';
import '../models/menu_model.dart';
import '../models/order_model.dart';
import '../models/cafe_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── CATEGORIES ──────────────────────────────

  Stream<List<CategoryModel>> getCategories(String cafeId) {
  return _db
      .collection('categories')
      .where('cafe_id', isEqualTo: cafeId)
      .where('is_active', isEqualTo: true)
      .snapshots()
      .map((snap) {
        final list = snap.docs
            .map((doc) => CategoryModel.fromFirestore(doc.data(), doc.id))
            .toList();
        // urutkan berdasarkan order di Flutter
        list.sort((a, b) => a.order.compareTo(b.order));
        return list;
      });
}

  Future<void> addCategory(CategoryModel category) async {
    await _db.collection('categories').add(category.toFirestore());
  }

  Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    await _db.collection('categories').doc(id).update(data);
  }

  Future<void> deleteCategory(String id) async {
    await _db.collection('categories').doc(id).delete();
  }

  // ── MENUS ────────────────────────────────────

  Stream<List<MenuModel>> getMenus(String cafeId) {
    return _db
        .collection('menus')
        .where('cafe_id', isEqualTo: cafeId)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => MenuModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Stream<List<MenuModel>> getMenusByCategory(String cafeId, String categoryId) {
    return _db
        .collection('menus')
        .where('cafe_id', isEqualTo: cafeId)
        .where('category_id', isEqualTo: categoryId)
        .where('is_available', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => MenuModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<void> addMenu(MenuModel menu) async {
    await _db.collection('menus').add(menu.toFirestore());
  }

  Future<void> updateMenu(String id, Map<String, dynamic> data) async {
    await _db.collection('menus').doc(id).update(data);
  }

  Future<void> deleteMenu(String id) async {
    await _db.collection('menus').doc(id).delete();
  }
  // ── CAFE ─────────────────────────────────────

Future<CafeModel?> getCafe(String cafeId) async {
  final doc = await _db.collection('cafes').doc(cafeId).get();
  if (doc.exists) {
    return CafeModel.fromFirestore(doc.data()!, doc.id);
  }
  return null;
}

  // ── ORDERS ───────────────────────────────────

  Stream<List<OrderModel>> getOrders(String cafeId) {
    return _db
        .collection('orders')
        .where('cafe_id', isEqualTo: cafeId)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => OrderModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<void> addOrder(OrderModel order) async {
    await _db.collection('orders').add(order.toFirestore());
  }

  Future<void> updateOrderStatus(String id, String status) async {
    await _db.collection('orders').doc(id).update({'status': status});
  }
}