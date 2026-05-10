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
  String? _selectedCategoryId; // null = All Menu
  bool _isLoading = true;

  // Warna tema sesuai desain
  static const Color _creamBg = Color(0xFFF2EBE0);
  static const Color _primaryBrown = Color(0xFF8B6F47);
  static const Color _darkBrown = Color(0xFF5D4037);
  static const Color _cardBeige = Color(0xFFE8DCC8);
  static const Color _lightBeige = Color(0xFFD4C4A8);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final cafe = await _firestoreService.getCafe(AppConstants.cafeId);
    setState(() => _cafe = cafe);

    _firestoreService.getCategories(AppConstants.cafeId).listen((cats) {
      setState(() => _categories = cats);
    });

    _firestoreService.getMenus(AppConstants.cafeId).listen((menus) {
      setState(() {
        _menus = menus;
        _isLoading = false;
      });
    });
  }

  List<MenuModel> get _filteredMenus {
    if (_selectedCategoryId == null) return _menus.where((m) => m.isAvailable).toList();
    return _menus.where((m) => m.categoryId == _selectedCategoryId && m.isAvailable).toList();
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
      backgroundColor: _creamBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                      const BorderRadius.vertical(top: Radius.circular(28)),
                  child: Image.network(
                    menu.imageUrl,
                    width: double.infinity,
                    height: 240,
                    fit: BoxFit.cover,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      menu.name,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold, color: _darkBrown),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppConstants.formatRupiah(menu.price),
                      style: const TextStyle(
                          fontSize: 18,
                          color: _primaryBrown,
                          fontWeight: FontWeight.bold),
                    ),
                    if (menu.description.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(
                        menu.description,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 14),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        if (qty > 0) ...[
                          InkWell(
                            onTap: () {
                              setModalState(() => qty--);
                              setState(() => _cart.decreaseItem(menu.id));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _primaryBrown,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.remove,
                                  color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              '$qty',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold, color: _darkBrown),
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
                              backgroundColor: _primaryBrown,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text(
                              qty == 0 ? 'Tambah ke Keranjang' : 'Tambah Lagi',
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
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
      backgroundColor: _creamBg,
      appBar: AppBar(
        backgroundColor: _creamBg,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _cafe?.name ?? 'Menu',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: _darkBrown,
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
              icon: const Icon(Icons.wifi, color: _primaryBrown),
              onPressed: _showWifiDialog,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: _primaryBrown,
              ),
            )
          : Stack(
              children: [
                Column(
                  children: [
                    // Header teks (satu baris, tanpa ikon profil)
                    const Padding(
                      padding: EdgeInsets.fromLTRB(24, 8, 24, 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Coffee so strong it keeps you on',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: _darkBrown,
                          ),
                        ),
                      ),
                    ),
                    // Category Tabs
                    _buildCategoryTabs(),
                    // Content
                    Expanded(
                      child: _selectedCategoryId == null
                          ? _buildAllMenu()
                          : _buildFilteredMenu(),
                    ),
                  ],
                ),
                // Floating Cart
                if (_cart.totalItems > 0)
                  Positioned(
                    bottom: 24,
                    left: 24,
                    right: 24,
                    child: GestureDetector(
                      onTap: _openCart,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: _primaryBrown,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _primaryBrown.withOpacity(0.4),
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
                              AppConstants.formatRupiah(_cart.totalPrice),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
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
    // Daftar tab default jika belum ada kategori
    final List<Map<String, dynamic>> defaultTabs = [
      {'id': null, 'name': 'All'},
      {'id': 'recommended', 'name': 'Recommended'},
      {'id': 'best', 'name': 'Best Ratings'},
    ];

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.isEmpty ? defaultTabs.length : _categories.length + 1,
        itemBuilder: (context, index) {
          String? catId;
          String catName;
          bool isSelected;

          if (_categories.isEmpty) {
            catId = defaultTabs[index]['id'] as String?;
            catName = defaultTabs[index]['name'] as String;
            isSelected = _selectedCategoryId == catId;
          } else {
            if (index == 0) {
              catId = null;
              catName = 'All';
              isSelected = _selectedCategoryId == null;
            } else {
              final cat = _categories[index - 1];
              catId = cat.id;
              catName = cat.name;
              isSelected = _selectedCategoryId == cat.id;
            }
          }

          return GestureDetector(
            onTap: () => setState(() => _selectedCategoryId = catId),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? _primaryBrown : _cardBeige,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: _primaryBrown.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              alignment: Alignment.center,
              child: Text(
                catName,
                style: TextStyle(
                  color: isSelected ? Colors.white : _darkBrown,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Semua menu dikelompokkan per kategori
  Widget _buildAllMenu() {
    return ListView(
      controller: _scrollController,
      padding: EdgeInsets.only(
        top: 16,
        left: 24,
        right: 24,
        bottom: _cart.totalItems > 0 ? 90 : 16,
      ),
      children: _categories.map((cat) {
        final menus = _menus
            .where((m) => m.categoryId == cat.id && m.isAvailable)
            .toList();
        if (menus.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12, top: 8),
              child: Text(
                cat.name,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: _darkBrown),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: menus.length,
              itemBuilder: (context, index) =>
                  _buildMenuCard(menus[index]),
            ),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  // Menu per kategori yang dipilih
  Widget _buildFilteredMenu() {
    final menus = _filteredMenus;

    if (menus.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fastfood, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Tidak ada menu di kategori ini',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.only(
        top: 16,
        left: 24,
        right: 24,
        bottom: _cart.totalItems > 0 ? 90 : 16,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: menus.length,
      itemBuilder: (context, index) => _buildMenuCard(menus[index]),
    );
  }

  Widget _buildMenuCard(MenuModel menu) {
    final itemInCart = _cart.items
        .where((i) => i.menu.id == menu.id)
        .fold(0, (sum, i) => sum + i.quantity);

    return GestureDetector(
      onTap: () => _showMenuDetail(menu),
      child: Container(
        decoration: BoxDecoration(
          color: _cardBeige,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _lightBeige,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: menu.imageUrl.isNotEmpty
                      ? Image.network(
                          menu.imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : const Center(
                          child: Icon(Icons.local_cafe,
                              size: 40, color: _primaryBrown),
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menu.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _darkBrown,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppConstants.formatRupiah(menu.price),
                        style: const TextStyle(
                          color: _primaryBrown,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      if (itemInCart > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _primaryBrown,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$itemInCart',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  itemInCart == 0
                      ? SizedBox(
                          width: double.infinity,
                          height: 32,
                          child: ElevatedButton(
                            onPressed: () =>
                                setState(() => _cart.addItem(menu)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryBrown,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Icon(Icons.add, size: 18),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () => setState(
                                  () => _cart.decreaseItem(menu.id)),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: _primaryBrown,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.remove,
                                    color: Colors.white, size: 14),
                              ),
                            ),
                            Text(
                              '$itemInCart',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: _darkBrown,
                              ),
                            ),
                            InkWell(
                              onTap: () =>
                                  setState(() => _cart.addItem(menu)),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: _primaryBrown,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.add,
                                    color: Colors.white, size: 14),
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
        backgroundColor: _creamBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.wifi, color: _primaryBrown),
            SizedBox(width: 8),
            Text('Info WiFi', style: TextStyle(color: _darkBrown)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nama WiFi:',
                style: TextStyle(fontWeight: FontWeight.bold, color: _darkBrown)),
            Text(_cafe?.wifiName ?? '-'),
            const SizedBox(height: 12),
            const Text('Password:',
                style: TextStyle(fontWeight: FontWeight.bold, color: _darkBrown)),
            Text(_cafe?.wifiPassword ?? '-'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(color: _primaryBrown)),
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