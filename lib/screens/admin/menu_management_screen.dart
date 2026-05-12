import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../../services/firestore_service.dart';
import '../../services/cloudinary_service.dart';
import '../../models/menu_model.dart';
import '../../models/category_model.dart';
import '../../utils/constants.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({Key? key}) : super(key: key);

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  final _firestoreService = FirestoreService();
  final _cloudinaryService = CloudinaryService();
  List<CategoryModel> _categories = [];

  // ─── TAMBAHAN: search controller & query ───
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // ─── WARNA TEMA WARM BROWN (sesuai gambar desain referensi) ───
  static const Color _primaryBrown = Color(0xFF8B6F47);
  static const Color _darkBrown = Color(0xFF5D4037);
  static const Color _lightBrown = Color(0xFFD4C4A8);
  static const Color _cream = Color(0xFFF2EBE0);
  static const Color _surfaceCream = Color(0xFFE8DCC8);
  static const Color _accentBrown = Color(0xFF8B6F47);

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  // ─── TAMBAHAN: dispose search controller ───
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadCategories() {
    _firestoreService.getCategories(AppConstants.cafeId).listen((cats) {
      if (mounted) {
        setState(() => _categories = cats);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MenuModel>>(
      stream: _firestoreService.getMenus(AppConstants.cafeId),
      builder: (context, menuSnapshot) {
        final menus = menuSnapshot.data ?? [];

        // ─── TAMBAHAN: filter menus berdasarkan search query ───
        final filteredMenus = _searchQuery.isEmpty
            ? menus
            : menus
                .where((m) =>
                    m.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    m.description
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                .toList();

        return Scaffold(
          backgroundColor: _cream,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showMenuDialog(context),
            backgroundColor: _primaryBrown,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Tambah Menu',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          body: Column(
            children: [
              // ─── TAMBAHAN: Search Bar ───
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: _darkBrown),
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Cari menu...',
                    hintStyle:
                        const TextStyle(color: _accentBrown, fontSize: 14),
                    prefixIcon:
                        const Icon(Icons.search, color: _accentBrown, size: 22),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                            child: const Icon(Icons.close,
                                color: _accentBrown, size: 20),
                          )
                        : null,
                    filled: true,
                    fillColor: _surfaceCream,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: _lightBrown),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: _lightBrown),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(color: _primaryBrown, width: 2),
                    ),
                  ),
                ),
              ),

              // ─── TAMBAHAN: label hasil pencarian ───
              if (_searchQuery.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${filteredMenus.length} hasil untuk "$_searchQuery"',
                      style: const TextStyle(
                        color: _accentBrown,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

              // ─── LIST (tidak diubah, hanya pakai filteredMenus) ───
              Expanded(
                child: filteredMenus.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isNotEmpty
                              ? 'Menu tidak ditemukan'
                              : 'Belum ada menu',
                          style: const TextStyle(
                            color: _accentBrown,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredMenus.length,
                        itemBuilder: (context, index) {
                          final menu = filteredMenus[index];
                          final category = _categories.firstWhere(
                            (c) => c.id == menu.categoryId,
                            orElse: () => CategoryModel(
                              id: '',
                              cafeId: '',
                              name: '-',
                              order: 0,
                              isActive: true,
                            ),
                          );
                          return _buildMenuCard(menu, category);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuCard(MenuModel menu, CategoryModel category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: _surfaceCream,
      elevation: 4,
      shadowColor: _primaryBrown.withOpacity(0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: menu.imageUrl.isNotEmpty
              ? Image.network(
                  menu.imageUrl,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _lightBrown,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_cafe,
                    color: _primaryBrown,
                    size: 28,
                  ),
                ),
        ),
        title: Text(
          menu.name,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: _darkBrown,
            letterSpacing: 0.2,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppConstants.formatRupiah(menu.price),
                style: const TextStyle(
                  color: _primaryBrown,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _lightBrown.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  category.name,
                  style: const TextStyle(
                    color: _darkBrown,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: menu.isAvailable,
              activeColor: _primaryBrown,
              activeTrackColor: _lightBrown,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey.shade300,
              onChanged: (val) {
                _firestoreService.updateMenu(menu.id, {'is_available': val});
              },
            ),
            // Tombol Edit
            Container(
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                color: _lightBrown.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(Icons.edit, color: _primaryBrown, size: 20),
                onPressed: () => _showMenuDialog(context, menu: menu),
                splashRadius: 20,
              ),
            ),
            // Tombol Hapus
            Container(
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                onPressed: () => _confirmDelete(context, menu),
                splashRadius: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, MenuModel menu) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _surfaceCream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          'Hapus Menu',
          style: TextStyle(
            color: _darkBrown,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Yakin ingin hapus "${menu.name}"?',
          style: const TextStyle(color: _accentBrown),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: _accentBrown, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () {
              _firestoreService.deleteMenu(menu.id);
              Navigator.pop(context);
            },
            child: const Text(
              'Hapus',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Satu dialog untuk tambah & edit
  void _showMenuDialog(BuildContext context, {MenuModel? menu}) {
    final isEdit = menu != null;
    final nameController = TextEditingController(text: menu?.name ?? '');
    final descController = TextEditingController(text: menu?.description ?? '');
    final priceController = TextEditingController(
        text: menu?.price != null ? menu!.price.toString() : '');
    String? selectedCategoryId = menu?.categoryId;
    File? selectedImage;
    Uint8List? selectedImageBytes;
    XFile? selectedXFile;
    String existingImageUrl = menu?.imageUrl ?? '';
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surfaceCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Indicator handle seperti di gambar tengah
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: _lightBrown,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Text(
                  isEdit ? 'Edit Menu' : 'Tambah Menu Baru',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _darkBrown,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 20),

                // Foto
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 70,
                    );
                    if (picked != null) {
                      final bytes = await picked.readAsBytes();
                      setModalState(() {
                        selectedXFile = picked;
                        selectedImageBytes = bytes;
                        if (!kIsWeb) {
                          selectedImage = File(picked.path);
                        }
                      });
                    }
                  },
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _lightBrown.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _lightBrown, width: 1.5),
                    ),
                    child: selectedImageBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.memory(
                              selectedImageBytes!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : existingImageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  existingImageUrl,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 44,
                                    color: _accentBrown,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Tap untuk pilih foto',
                                    style: TextStyle(
                                      color: _accentBrown,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: nameController,
                  style: const TextStyle(color: _darkBrown),
                  decoration: InputDecoration(
                    labelText: 'Nama Menu',
                    labelStyle: const TextStyle(color: _accentBrown),
                    filled: true,
                    fillColor: _cream,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: _lightBrown),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: _lightBrown),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: _primaryBrown, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: descController,
                  style: const TextStyle(color: _darkBrown),
                  decoration: InputDecoration(
                    labelText: 'Deskripsi',
                    labelStyle: const TextStyle(color: _accentBrown),
                    filled: true,
                    fillColor: _cream,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: _lightBrown),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: _lightBrown),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: _primaryBrown, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: _darkBrown),
                  decoration: InputDecoration(
                    labelText: 'Harga',
                    labelStyle: const TextStyle(color: _accentBrown),
                    prefixText: 'Rp ',
                    prefixStyle: const TextStyle(
                      color: _primaryBrown,
                      fontWeight: FontWeight.w600,
                    ),
                    filled: true,
                    fillColor: _cream,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: _lightBrown),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: _lightBrown),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: _primaryBrown, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                DropdownButtonFormField<String>(
                  value: selectedCategoryId,
                  style: const TextStyle(color: _darkBrown),
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    labelStyle: const TextStyle(color: _accentBrown),
                    filled: true,
                    fillColor: _cream,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: _lightBrown),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: _lightBrown),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: _primaryBrown, width: 2),
                    ),
                  ),
                  items: _categories
                      .map(
                        (c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name),
                        ),
                      )
                      .toList(),
                  onChanged: (val) =>
                      setModalState(() => selectedCategoryId = val),
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (nameController.text.isEmpty ||
                                priceController.text.isEmpty ||
                                selectedCategoryId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Lengkapi semua field!'),
                                  backgroundColor: _darkBrown,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(12),
                                    ),
                                  ),
                                ),
                              );
                              return;
                            }

                            setModalState(() => isLoading = true);

                            // Upload foto baru kalau ada
                            String imageUrl = existingImageUrl;
                            if (selectedXFile != null) {
                              if (kIsWeb) {
                                imageUrl = await _cloudinaryService.uploadImageWeb(
                                        selectedImageBytes!) ??
                                    existingImageUrl;
                              } else {
                                imageUrl = await _cloudinaryService.uploadImage(
                                        selectedImage!) ??
                                    existingImageUrl;
                              }
                            }

                            if (isEdit) {
                              // Update menu
                              await _firestoreService.updateMenu(menu!.id, {
                                'name': nameController.text,
                                'description': descController.text,
                                'price': int.parse(priceController.text),
                                'category_id': selectedCategoryId,
                                'image_url': imageUrl,
                              });
                            } else {
                              // Tambah menu baru
                              final newMenu = MenuModel(
                                id: '',
                                cafeId: AppConstants.cafeId,
                                categoryId: selectedCategoryId!,
                                name: nameController.text,
                                description: descController.text,
                                price: int.parse(priceController.text),
                                imageUrl: imageUrl,
                                isAvailable: true,
                              );
                              await _firestoreService.addMenu(newMenu);
                            }

                            if (context.mounted) Navigator.pop(context);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryBrown,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: _primaryBrown.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            isEdit ? 'Simpan Perubahan' : 'Simpan Menu',
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}