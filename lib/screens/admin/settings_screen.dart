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
          content: Text('Pengaturan berhasil disimpan!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Info Cafe',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nama Cafe',
                prefixIcon: const Icon(Icons.store),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _addressController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Alamat',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),

            const Text('Kontak',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            TextField(
              controller: _waController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Nomor WhatsApp',
                hintText: '6281234567890',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),

            const Text('WiFi',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            TextField(
              controller: _wifiNameController,
              decoration: InputDecoration(
                labelText: 'Nama WiFi',
                prefixIcon: const Icon(Icons.wifi),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _wifiPassController,
              decoration: InputDecoration(
                labelText: 'Password WiFi',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Simpan Pengaturan',
                        style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
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