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
      appBar: AppBar(
        title: const Text('Keranjang'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: widget.cart.isEmpty
          ? const Center(
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
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.cart.items.length,
                    itemBuilder: (context, index) {
                      final item = widget.cart.items[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: item.menu.imageUrl.isNotEmpty
                                    ? Image.network(item.menu.imageUrl,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover)
                                    : Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.orange.shade100,
                                        child: const Icon(Icons.fastfood,
                                            color: Colors.orange)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.menu.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                      AppConstants.formatRupiah(item.menu.price),
                                      style: const TextStyle(
                                          color: Colors.orange),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle,
                                        color: Colors.orange),
                                    onPressed: () {
                                      setState(() {
                                        widget.cart.decreaseItem(item.menu.id);
                                        widget.onCartUpdated();
                                      });
                                    },
                                  ),
                                  Text('${item.quantity}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle,
                                        color: Colors.orange),
                                    onPressed: () {
                                      setState(() {
                                        widget.cart.addItem(item.menu);
                                        widget.onCartUpdated();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _tableController,
                        decoration: InputDecoration(
                          labelText: 'Nomor Meja atau Nama',
                          hintText: 'contoh: Meja 3/Budi',
                          prefixIcon: const Icon(Icons.table_restaurant),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(
                            AppConstants.formatRupiah(widget.cart.totalPrice),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.orange),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _checkout,
                          icon: const FaIcon(FontAwesomeIcons.whatsapp),
                          label: const Text('Pesan via WhatsApp',
                              style: TextStyle(fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
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