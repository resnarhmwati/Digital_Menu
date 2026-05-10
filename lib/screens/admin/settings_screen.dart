import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _db = FirebaseFirestore.instance;
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _waController = TextEditingController();
  final _wifiNameController = TextEditingController();
  final _wifiPassController = TextEditingController();
  bool _isLoading = false;
  bool _isSaving = false;

  // ─── WARNA TEMA ───
  static const Color _brown = Color(0xFF8D6E63);
  static const Color _darkBrown = Color(0xFF5D4037);
  static const Color _cream = Color(0xFFF5F0EB);
  static const Color _surface = Color(0xFFFFF8F0);
  static const Color _lightBrown = Color(0xFFD7CCC8);
  static const Color _accentBrown = Color(0xFFA1887F);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    final doc = await _db.collection('cafes').doc(AppConstants.cafeId).get();
    if (doc.exists) {
      final data = doc.data()!;
      _nameController.text = data['name'] ?? '';
      _addressController.text = data['address'] ?? '';
      _waController.text = data['whatsapp'] ?? '';
      _wifiNameController.text = data['wifi_name'] ?? '';
      _wifiPassController.text = data['wifi_password'] ?? '';
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    await _db.collection('cafes').doc(AppConstants.cafeId).update({
      'name': _nameController.text,
      'address': _addressController.text,
      'whatsapp': _waController.text,
      'wifi_name': _wifiNameController.text,
      'wifi_password': _wifiPassController.text,
    });
    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pengaturan berhasil disimpan!',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: _darkBrown,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _brown),
      );
    }

    return Scaffold(
      backgroundColor: _cream,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Info Cafe'),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _nameController,
              label: 'Nama Cafe',
              icon: Icons.store_outlined,
            ),
            const SizedBox(height: 14),
            _buildTextField(
              controller: _addressController,
              label: 'Alamat',
              icon: Icons.location_on_outlined,
              maxLines: 2,
            ),
            const SizedBox(height: 28),

            _buildSectionTitle('Kontak'),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _waController,
              label: 'Nomor WhatsApp',
              icon: Icons.phone_outlined,
              hint: '6281234567890',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 28),

            _buildSectionTitle('WiFi'),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _wifiNameController,
              label: 'Nama WiFi',
              icon: Icons.wifi_outlined,
            ),
            const SizedBox(height: 14),
            _buildTextField(
              controller: _wifiPassController,
              label: 'Password WiFi',
              icon: Icons.lock_outline,
            ),
            const SizedBox(height: 36),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brown,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: _brown.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text('Simpan Pengaturan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: _darkBrown,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: _darkBrown),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _accentBrown),
        hintText: hint,
        hintStyle: TextStyle(color: _darkBrown.withOpacity(0.35)),
        prefixIcon: Icon(icon, color: _accentBrown),
        filled: true,
        fillColor: _surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
          borderSide: const BorderSide(color: _brown, width: 2),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _waController.dispose();
    _wifiNameController.dispose();
    _wifiPassController.dispose();
    super.dispose();
  }
}