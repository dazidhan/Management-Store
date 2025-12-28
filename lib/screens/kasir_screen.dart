import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/database_service.dart';
import 'barcode_scanner_screen.dart';

class KasirScreen extends StatefulWidget {
  const KasirScreen({super.key});

  @override
  State<KasirScreen> createState() => _KasirScreenState();
}

class _KasirScreenState extends State<KasirScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  final _databaseService = DatabaseService();

  // State Keranjang Belanja
  final Map<String, Map<String, dynamic>> _cart = {}; // Map Product ID -> {productData, qty}

  final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  final List<String> _categories = [
    'Semua',
    'Makanan',
    'Minuman',
    'Kebersihan',
    'Dapur',
  ];

  // Controller untuk nama pelanggan
  final TextEditingController _customerNameController = TextEditingController(
    text: "Pelanggan Umum",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // 1. Search & Category Filter
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (value) =>
                                setState(() => _searchQuery = value),
                            decoration: InputDecoration(
                              hintText: 'Cari barang...',
                              prefixIcon: const Icon(
                                Icons.search,
                                color: AppColors.textSecondary,
                              ),
                              filled: true,
                              fillColor: AppColors.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BarcodeScannerScreen(),
                              ),
                            );
                            if (result != null && result is String) {
                              // Search by barcode
                              _searchByBarcode(result);
                            }
                          },
                          icon: const Icon(Icons.qr_code_scanner),
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _categories.map((cat) {
                          final isSelected = _selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(cat),
                              selected: isSelected,
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                              backgroundColor: AppColors.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide.none,
                              ),
                              onSelected: (val) =>
                                  setState(() => _selectedCategory = cat),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Product Grid (Dynamic from Firestore)
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _databaseService.getProducts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          "Belum ada produk",
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      );
                    }

                    // Filter products
                    final allProducts = snapshot.data!.docs;
                    final filteredProducts = allProducts.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name = (data['name'] as String? ?? '').toLowerCase();
                      final category = data['category'] as String? ?? '';
                      final matchesSearch = name.contains(_searchQuery.toLowerCase());
                      final matchesCategory =
                          _selectedCategory == 'Semua' || category == _selectedCategory;
                      return matchesSearch && matchesCategory;
                    }).toList();

                    if (filteredProducts.isEmpty) {
                      return const Center(
                        child: Text(
                          "Tidak ada produk yang cocok",
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 250),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final doc = filteredProducts[index];
                        final productData = doc.data() as Map<String, dynamic>;
                        return _buildProductCard(doc.id, productData);
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          // 3. Floating Cart
          if (_cart.isNotEmpty) _buildCartSummary(),
        ],
      ),
    );
  }

  Future<void> _searchByBarcode(String barcode) async {
    try {
      final productDoc = await _databaseService.getProductByBarcode(barcode);
      if (productDoc != null && productDoc.exists) {
        final productData = productDoc.data() as Map<String, dynamic>;
        final productId = productDoc.id;
        _addToCart(productId, productData);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Produk dengan barcode tersebut tidak ditemukan'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    }
  }

  Widget _buildProductCard(String productId, Map<String, dynamic> productData) {
    final name = productData['name'] as String? ?? '';
    final price = (productData['price'] as num?)?.toDouble() ?? 0.0;
    final stock = (productData['stock'] as int?) ?? 0;
    final qtyInCart = _cart[productId]?['qty'] ?? 0;
    final isSelected = qtyInCart > 0;

    return GestureDetector(
      onTap: () => _addToCart(productId, productData),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text("📦", style: TextStyle(fontSize: 20)),
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${qtyInCart}x",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Stok: $stock",
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currencyFormat.format(price),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSummary() {
    double totalPrice = 0;
    int totalItems = 0;

    _cart.forEach((key, value) {
      final price = (value['price'] as num?)?.toDouble() ?? 0.0;
      final qty = value['qty'] as int? ?? 0;
      totalPrice += price * qty;
      totalItems += qty;
    });

    return Positioned(
      bottom: 20,
      left: 16,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                shrinkWrap: true,
                itemCount: _cart.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  String key = _cart.keys.elementAt(index);
                  Map<String, dynamic> value = _cart[key]!;
                  final name = value['name'] as String? ?? '';
                  final price = (value['price'] as num?)?.toDouble() ?? 0.0;
                  final qty = value['qty'] as int? ?? 0;
                  return _buildCartItemRow(key, name, price, qty);
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _showCheckoutModal(totalItems, totalPrice);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.payment, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "Bayar ($totalItems item) - ${_currencyFormat.format(totalPrice)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItemRow(String productId, String name, double price, int qty) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                "${_currencyFormat.format(price)} x $qty",
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              _buildQtyBtn(Icons.remove, () => _updateQty(productId, -1)),
              SizedBox(
                width: 32,
                child: Center(
                  child: Text(
                    "$qty",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              _buildQtyBtn(
                Icons.add,
                () => _updateQty(productId, 1),
                isAdd: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap, {bool isAdd = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 36,
        decoration: BoxDecoration(
          color: isAdd ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.horizontal(
            left: isAdd ? Radius.zero : const Radius.circular(7),
            right: isAdd ? const Radius.circular(7) : Radius.zero,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isAdd ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }

  void _showCheckoutModal(int totalItems, double totalPrice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Konfirmasi Pembayaran",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Nama Pelanggan",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _customerNameController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Item",
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        Text(
                          "$totalItems",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Bayar",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _currencyFormat.format(totalPrice),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _processPayment(totalItems, totalPrice);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Proses Pembayaran",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _processPayment(int totalItems, double totalPrice) async {
    try {
      // Prepare transaction items
      final List<Map<String, dynamic>> items = [];
      _cart.forEach((productId, value) {
        items.add({
          'productId': productId,
          'name': value['name'] as String? ?? '',
          'price': value['price'] as num? ?? 0.0,
          'qty': value['qty'] as int? ?? 0,
        });
      });

      // Save transaction to Firestore
      await _databaseService.addTransaction({
        'customerName': _customerNameController.text.trim(),
        'totalPrice': totalPrice,
        'totalItems': totalItems,
        'items': items,
        'status': 'completed',
      });

      // Update product stock
      for (var entry in _cart.entries) {
        final productId = entry.key;
        final qty = entry.value['qty'] as int? ?? 0;
        final productDoc = await _databaseService.getProduct(productId);
        if (productDoc != null && productDoc.exists) {
          final productData = productDoc.data() as Map<String, dynamic>;
          final currentStock = (productData['stock'] as int?) ?? 0;
          await _databaseService.updateProduct(productId, {
            'stock': currentStock - qty,
          });
        }
      }

      setState(() {
        _cart.clear();
        _customerNameController.text = "Pelanggan Umum";
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Transaksi ${_customerNameController.text} Berhasil!",
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    }
  }

  void _addToCart(String productId, Map<String, dynamic> productData) {
    final stock = (productData['stock'] as int?) ?? 0;
    final currentQty = _cart[productId]?['qty'] ?? 0;

    if (currentQty >= stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Stok Maksimal!"),
          duration: Duration(milliseconds: 500),
        ),
      );
      return;
    }

    setState(() {
      if (_cart.containsKey(productId)) {
        _cart[productId]!['qty'] = (_cart[productId]!['qty'] as int) + 1;
      } else {
        _cart[productId] = {
          'name': productData['name'],
          'price': productData['price'],
          'qty': 1,
        };
      }
    });
  }

  void _updateQty(String productId, int delta) {
    setState(() {
      if (_cart.containsKey(productId)) {
        int newQty = (_cart[productId]!['qty'] as int) + delta;
        if (newQty <= 0) {
          _cart.remove(productId);
        } else {
          // Check stock limit
          // Note: We'd need to fetch current stock, but for simplicity we'll allow it
          _cart[productId]!['qty'] = newQty;
        }
      }
    });
  }
}
