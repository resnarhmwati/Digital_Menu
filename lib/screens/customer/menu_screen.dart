import 'package:flutter/material.dart';
import '../../models/cafe_model.dart';
import '../../models/menu_model.dart';
import '../../models/category_model.dart';
import '../../models/cart_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import 'cart_screen.dart';

class CustomerMenuScreen extends StatefulWidget {
  const CustomerMenuScreen({Key? key}) : super(key: key);

  @override
  State<CustomerMenuScreen> createState() => _CustomerMenuScreenState();
}

class _CustomerMenuScreenState extends State<CustomerMenuScreen> {
  final _firestoreService = FirestoreService();
  final Cart _cart = Cart();
  final ScrollController _scrollController = ScrollController();
  CafeModel? _cafe;
  List<CategoryModel> _categories = [];
  List<MenuModel> _menus = [];
  String? _selectedCategoryId;
  bool _isLoading = true;
  final Map<String, GlobalKey> _categoryKeys = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final cafe = await _firestoreService.getCafe(AppConstants.cafeId);
    setState(() => _cafe = cafe);

    _firestoreService.getCategories(AppConstants.cafeId).listen((cats) {
      setState(() {
        _categories = cats;
        for (final cat in cats) {
          _categoryKeys.putIfAbsent(cat.id, () => GlobalKey());
        }
      });
    });

    _firestoreService.getMenus(AppConstants.cafeId).listen((menus) {
      setState(() {
        _menus = menus;
        _isLoading = false;
      });
    });
  }

  void _scrollToCategory(String? categoryId) {
    setState(() => _selectedCategoryId = categoryId);

    if (categoryId == null) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    final key = _categoryKeys[categoryId];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _openCart() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CartScreen(
          cart: _cart,
          whatsapp: _cafe?.whatsapp ?? '',
          onCartUpdated: () => setState(() {}),
        ),
      ),
    );
    setState(() {});
  }

  void _showMenuDetail(MenuModel menu) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          int qty = _cart.items
              .where((i) => i.menu.id == menu.id)
              .fold(0, (sum, i) => sum + i.quantity);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (menu.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    menu.imageUrl,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      menu.name,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppConstants.formatRupiah(menu.price),
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold),
                    ),
                    if (menu.description.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        menu.description,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        if (qty > 0) ...[
                          InkWell(
                            onTap: () {
                              setModalState(() => qty--);
                              setState(() => _cart.decreaseItem(menu.id));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.remove,
                                  color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '$qty',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setModalState(() => qty++);
                              setState(() => _cart.addItem(menu));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              qty == 0
                                  ? 'Tambah ke Keranjang'
                                  : 'Tambah Lagi',
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _cafe?.name ?? 'Menu',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            if (_cafe?.address != null)
              Text(
                _cafe!.address,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
          ],
        ),
        actions: [
          if (_cafe?.wifiName != null && _cafe!.wifiName.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.wifi, color: Colors.orange),
              onPressed: _showWifiDialog,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Column(
                  children: [
                    _buildCategoryTabs(),
                    Expanded(
                      child: ListView(
                        controller: _scrollController,
                        padding: EdgeInsets.only(
                          top: 16,
                          left: 16,
                          right: 16,
                          bottom: _cart.totalItems > 0 ? 90 : 16,
                        ),
                        children: _categories.map((cat) {
                          final menus = _menus
                              .where((m) =>
                                  m.categoryId == cat.id && m.isAvailable)
                              .toList();
                          if (menus.isEmpty) return const SizedBox.shrink();
                          return _buildCategorySection(cat, menus);
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                if (_cart.totalItems > 0)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: GestureDetector(
                      onTap: _openCart,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${_cart.totalItems} item',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Lihat Keranjang',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Text(
  AppConstants.formatRupiah(_cart.totalPrice), // Ganti ke sini
  style: const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 15,
  ),
)
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      color: Colors.white,
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          GestureDetector(
            onTap: () => _scrollToCategory(null),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: _selectedCategoryId == null
                    ? Colors.orange
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'All Menu',
                style: TextStyle(
                  color: _selectedCategoryId == null
                      ? Colors.white
                      : Colors.black,
                  fontWeight: _selectedCategoryId == null
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          ),
          ..._categories.map((cat) {
            final isSelected = cat.id == _selectedCategoryId;
            return GestureDetector(
              onTap: () => _scrollToCategory(cat.id),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.orange : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  cat.name,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategorySection(CategoryModel cat, List<MenuModel> menus) {
    return Column(
      key: _categoryKeys[cat.id],
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 8),
          child: Text(
            cat.name,
            style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: menus.length,
          itemBuilder: (context, index) => _buildMenuCard(menus[index]),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMenuCard(MenuModel menu) {
    final itemInCart = _cart.items
        .where((i) => i.menu.id == menu.id)
        .fold(0, (sum, i) => sum + i.quantity);

    return GestureDetector(
      onTap: () => _showMenuDetail(menu),
      child: Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: menu.imageUrl.isNotEmpty
                    ? Image.network(
                        menu.imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.orange.shade100,
                        child: const Center(
                          child: Icon(Icons.fastfood,
                              size: 40, color: Colors.orange),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menu.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    AppConstants.formatRupiah(menu.price),
                    style: const TextStyle(color: Colors.orange),
                  ),
                  const SizedBox(height: 4),
                  itemInCart == 0
                      ? SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () =>
                                setState(() => _cart.addItem(menu)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('+',
                                style: TextStyle(fontSize: 18)),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () => setState(
                                  () => _cart.decreaseItem(menu.id)),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.remove,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                            Text(
                              '$itemInCart',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            InkWell(
                              onTap: () =>
                                  setState(() => _cart.addItem(menu)),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.add,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWifiDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.wifi, color: Colors.orange),
            SizedBox(width: 8),
            Text('Info WiFi'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nama WiFi:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(_cafe?.wifiName ?? '-'),
            const SizedBox(height: 12),
            const Text('Password:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(_cafe?.wifiPassword ?? '-'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}