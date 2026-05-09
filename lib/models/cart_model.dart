import 'menu_model.dart';

class CartItem {
  final MenuModel menu;
  int quantity;

  CartItem({
    required this.menu,
    required this.quantity,
  });

  int get subtotal => menu.price * quantity;
}

class Cart {
  final List<CartItem> items = [];

  void addItem(MenuModel menu) {
    final existing = items.indexWhere((i) => i.menu.id == menu.id);
    if (existing >= 0) {
      items[existing].quantity++;
    } else {
      items.add(CartItem(menu: menu, quantity: 1));
    }
  }

  void removeItem(String menuId) {
    items.removeWhere((i) => i.menu.id == menuId);
  }

  void decreaseItem(String menuId) {
    final existing = items.indexWhere((i) => i.menu.id == menuId);
    if (existing >= 0) {
      if (items[existing].quantity > 1) {
        items[existing].quantity--;
      } else {
        items.removeAt(existing);
      }
    }
  }

  void clear() => items.clear();

  int get totalItems => items.fold(0, (sum, i) => sum + i.quantity);

  int get totalPrice => items.fold(0, (sum, i) => sum + i.subtotal);

  bool get isEmpty => items.isEmpty;
}