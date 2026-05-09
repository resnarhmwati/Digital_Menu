import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
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

  @override
  void initState() {
    super.initState();
    _loadCategories();
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

        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddMenuDialog(context),
            backgroundColor: Colors.orange,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Tambah Menu',
                style: TextStyle(color: Colors.white)),
          ),
          body: menus.isEmpty
              ? const Center(
                  child: Text('Belum ada menu',
                      style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: menus.length,
                  itemBuilder: (context, index) {
                    final menu = menus[index];
                    final category = _categories.firstWhere(
                      (c) => c.id == menu.categoryId,
                      orElse: () => CategoryModel(
                          id: '',
                          cafeId: '',
                          name: '-',
                          order: 0,
                          isActive: true),
                    );
                    return _buildMenuCard(menu, category);
                  },
                ),
        );
      },
    );
  }

  Widget _buildMenuCard(MenuModel menu, CategoryModel category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: menu.imageUrl.isNotEmpty
              ? Image.network(menu.imageUrl,
                  width: 60, height: 60, fit: BoxFit.cover)
              : Container(
                  width: 60,
                  height: 60,
                  color: Colors.orange.shade100,
                  child: const Icon(Icons.fastfood, color: Colors.orange)),
        ),
        title: Text(menu.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rp ${menu.price}'),
            Text(category.name,
                style: const TextStyle(color: Colors.orange, fontSize: 12)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: menu.isAvailable,
              activeColor: Colors.orange,
              onChanged: (val) {
                _firestoreService.updateMenu(menu.id, {'is_available': val});
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context, menu),
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
        title: const Text('Hapus Menu'),
        content: Text('Yakin ingin hapus "${menu.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          TextButton(
            onPressed: () {
              _firestoreService.deleteMenu(menu.id);
              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddMenuDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();
    String? selectedCategoryId;
    File? selectedImage;
    Uint8List? selectedImageBytes;
    XFile? selectedXFile;
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                const Text('Tambah Menu Baru',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                // Foto
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(
                        source: ImageSource.gallery, imageQuality: 70);
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
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: selectedImageBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(selectedImageBytes!,
                                fit: BoxFit.cover))
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate,
                                  size: 40, color: Colors.orange),
                              Text('Tap untuk pilih foto'),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Menu',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Harga',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: _categories
                      .map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ))
                      .toList(),
                  onChanged: (val) =>
                      setModalState(() => selectedCategoryId = val),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (nameController.text.isEmpty ||
                                priceController.text.isEmpty ||
                                selectedCategoryId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Lengkapi semua field!')),
                              );
                              return;
                            }

                            setModalState(() => isLoading = true);

                            String imageUrl = '';
                            if (selectedXFile != null) {
                              if (kIsWeb) {
                                imageUrl = await _cloudinaryService
                                        .uploadImageWeb(selectedImageBytes!) ??
                                    '';
                              } else {
                                imageUrl = await _cloudinaryService
                                        .uploadImage(selectedImage!) ??
                                    '';
                              }
                            }

                            final menu = MenuModel(
                              id: '',
                              cafeId: AppConstants.cafeId,
                              categoryId: selectedCategoryId!,
                              name: nameController.text,
                              description: descController.text,
                              price: int.parse(priceController.text),
                              imageUrl: imageUrl,
                              isAvailable: true,
                            );

                            await _firestoreService.addMenu(menu);
                            if (context.mounted) Navigator.pop(context);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Simpan Menu',
                            style: TextStyle(fontSize: 16)),
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