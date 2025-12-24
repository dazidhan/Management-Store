import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/dummy_data.dart';

class KasirScreen extends StatefulWidget {
  const KasirScreen({super.key});

  @override
  State<KasirScreen> createState() => _KasirScreenState();
}

class _KasirScreenState extends State<KasirScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  // State Keranjang Belanja
  final Map<String, int> _cart = {}; // Map Product ID -> Qty

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
    // Filter Logic
    final filteredProducts = dummyProducts.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchesCategory =
          _selectedCategory == 'Semua' || p.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

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
                    TextField(
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

              // 2. Product Grid
              Expanded(
                child: filteredProducts.isEmpty
                    ? const Center(
                        child: Text(
                          "Belum ada produk",
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : GridView.builder(
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
                          return _buildProductCard(filteredProducts[index]);
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

  // --- WIDGETS ---

  Widget _buildProductCard(Product product) {
    final qtyInCart = _cart[product.id] ?? 0;
    final isSelected = qtyInCart > 0;

    return GestureDetector(
      onTap: () => _addToCart(product),
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
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Stok: ${product.stock}",
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currencyFormat.format(product.price),
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

    _cart.forEach((key, qty) {
      final product = dummyProducts.firstWhere((p) => p.id == key);
      totalPrice += product.price * qty;
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
                  int qty = _cart[key]!;
                  final product = dummyProducts.firstWhere((p) => p.id == key);
                  return _buildCartItemRow(product, qty);
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
                    // Panggil Modal Konfirmasi Pembayaran
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

  Widget _buildCartItemRow(Product product, int qty) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                "${_currencyFormat.format(product.price)} x $qty",
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
              _buildQtyBtn(Icons.remove, () => _updateQty(product.id, -1)),
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
                () => _updateQty(product.id, 1),
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

  // --- MODAL KONFIRMASI PEMBAYARAN (Update Baru) ---
  void _showCheckoutModal(int totalItems, double totalPrice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Agar modal bisa menyesuaikan tinggi keyboard
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
            bottom:
                MediaQuery.of(context).viewInsets.bottom +
                24, // Padding keyboard
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
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Input Nama Pelanggan
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
                style: const TextStyle(color: Colors.white),
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
                    ), // Warna Hijau saat aktif
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Kotak Ringkasan Total
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background.withOpacity(
                    0.5,
                  ), // Background agak gelap
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

              // Tombol Proses
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Tutup Modal
                    _processPayment(totalItems, totalPrice); // Proses data
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

  // Logic setelah tombol "Proses Pembayaran" ditekan
  void _processPayment(int totalItems, double totalPrice) {
    setState(() {
      _cart.clear(); // Kosongkan keranjang
    });

    // Tampilkan notifikasi sukses
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

  // --- LOGIC ---

  void _addToCart(Product product) {
    setState(() {
      if (_cart.containsKey(product.id)) {
        if (_cart[product.id]! < product.stock) {
          _cart[product.id] = _cart[product.id]! + 1;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Stok Maksimal!"),
              duration: Duration(milliseconds: 500),
            ),
          );
        }
      } else {
        _cart[product.id] = 1;
      }
    });
  }

  void _updateQty(String productId, int delta) {
    setState(() {
      if (_cart.containsKey(productId)) {
        int newQty = _cart[productId]! + delta;
        final product = dummyProducts.firstWhere((p) => p.id == productId);

        if (newQty <= 0) {
          _cart.remove(productId);
        } else if (newQty <= product.stock) {
          _cart[productId] = newQty;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Stok Maksimal!"),
              duration: Duration(milliseconds: 500),
            ),
          );
        }
      }
    });
  }
}
