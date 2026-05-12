import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/cart_model.dart';
import '../../utils/constants.dart';

class CartScreen extends StatefulWidget {
  final Cart cart;
  final String whatsapp;
  final VoidCallback onCartUpdated;

  const CartScreen({
    Key? key,
    required this.cart,
    required this.whatsapp,
    required this.onCartUpdated,
  }) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _tableController = TextEditingController();

  // Warna tema sesuai desain
  static const Color _creamBg = Color(0xFFF2EBE0);
  static const Color _primaryBrown = Color(0xFF8B6F47);
  static const Color _darkBrown = Color(0xFF5D4037);
  static const Color _cardBeige = Color(0xFFE8DCC8);
  static const Color _lightBeige = Color(0xFFD4C4A8);

  String _buildWhatsAppMessage() {
    final buffer = StringBuffer();
    buffer.writeln('Halo, saya mau pesan:');
    buffer.writeln('');
    for (final item in widget.cart.items) {
      buffer.writeln(
          '- ${item.menu.name} x${item.quantity} = ${AppConstants.formatRupiah(item.subtotal)}');
    }
    buffer.writeln('');
    buffer.writeln(
        'Total: ${AppConstants.formatRupiah(widget.cart.totalPrice)}');
    buffer.writeln('Meja/Nama: ${_tableController.text}');
    return buffer.toString();
  }

  Future<void> _checkout() async {
    if (_tableController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan nomor meja/nama dulu!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keranjang masih kosong!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final message = Uri.encodeComponent(_buildWhatsAppMessage());
    final url = 'https://wa.me/${widget.whatsapp}?text=$message';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _primaryBrown,
      appBar: AppBar(
        backgroundColor: _primaryBrown,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Cart',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20, top: 8),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withOpacity(0.9),
              child: Text(
                '${widget.cart.totalItems}',
                style: const TextStyle(
                  color: _primaryBrown,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      body: widget.cart.isEmpty
          ? Container(
              color: _creamBg,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_outlined,
                        size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Keranjang masih kosong',
                        style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: _creamBg,
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      itemCount: widget.cart.items.length,
                      itemBuilder: (context, index) {
                        final item = widget.cart.items[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: _cardBeige,
                                backgroundImage: item.menu.imageUrl.isNotEmpty
                                    ? NetworkImage(item.menu.imageUrl)
                                    : null,
                                child: item.menu.imageUrl.isEmpty
                                    ? const Icon(
                                        Icons.local_cafe,
                                        color: _primaryBrown,
                                        size: 24,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.menu.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: _darkBrown,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.menu.description.isNotEmpty
                                          ? item.menu.description
                                          : 'creamy with a hint of whisky',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _primaryBrown,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  AppConstants.formatRupiah(item.menu.price),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  color: _creamBg,
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    children: [
                      // Nomor Meja
                      TextField(
                        controller: _tableController,
                        style: const TextStyle(color: _darkBrown),
                        decoration: InputDecoration(
                          labelText: 'Nomor Meja atau Nama',
                          labelStyle: const TextStyle(color: Colors.grey),
                          hintText: 'contoh: Meja 3/Budi',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          filled: true,
                          fillColor: _cardBeige.withOpacity(0.5),
                          prefixIcon: const Icon(Icons.table_restaurant,
                              color: _primaryBrown),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Summary Card - hanya Total Amount
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: _primaryBrown,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              AppConstants.formatRupiah(
                                  widget.cart.totalPrice),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Make Payment Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _checkout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryBrown,
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shadowColor: _primaryBrown.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Text(
                                  'Make payment',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _tableController.dispose();
    super.dispose();
  }
}