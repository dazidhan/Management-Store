import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/dummy_data.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  String _searchQuery = '';
  final _formKey = GlobalKey<FormState>();

  // Controllers untuk Form
  final _skuController = TextEditingController();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _minStockController = TextEditingController(text: '10');
  String _selectedCategory = 'Makanan';

  // ID produk yang sedang diedit (null jika mode tambah baru)
  String? _editingProductId;

  // Format Rupiah
  final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    // Filter produk berdasarkan search
    final filteredProducts = dummyProducts.where((p) {
      return p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.sku.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Manajemen Stok",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${filteredProducts.length} produk",
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                // Tombol Tambah Baru
                InkWell(
                  onTap: () =>
                      _showProductForm(null), // Null artinya mode tambah
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search Bar
            TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Cari nama atau SKU...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Stock List (Tampilan Baru)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredProducts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildStockCard(filteredProducts[index]);
              },
            ),
            const SizedBox(height: 80), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  // --- WIDGET KARTU STOK BARU (Sesuai Gambar) ---
  Widget _buildStockCard(Product product) {
    bool isLowStock = product.stock <= product.minStock;

    return GestureDetector(
      onTap: () {
        _showProductForm(product); // Buka modal edit saat diklik
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface, // bg-card
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border), // border-border
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 1. Icon Box (Sesuai Kategori)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.secondary, // bg-secondary
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _getCategoryIcon(product.category),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // 2. Info Produk
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
                  const SizedBox(height: 2),
                  Text(
                    "SKU: ${product.sku} • ${product.category}",
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currencyFormat.format(product.price),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary, // text-primary
                    ),
                  ),
                ],
              ),
            ),

            // 3. Status Stok & Edit
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${product.stock}",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    // text-destructive if low, else text-white
                    color: isLowStock ? AppColors.danger : Colors.white,
                  ),
                ),
                Text(
                  "Min: ${product.minStock}",
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                // Indikator Edit (Visual saja)
                const Text(
                  "Edit >",
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryIcon(String category) {
    if (category == 'Makanan') return '🍜';
    if (category == 'Minuman') return '🥤';
    return '📦';
  }

  // --- MODAL FORM (BISA UNTUK TAMBAH & EDIT) ---
  void _showProductForm(Product? product) {
    // Reset atau Isi Controller
    if (product != null) {
      _editingProductId = product.id;
      _skuController.text = product.sku;
      _nameController.text = product.name;
      _priceController.text = product.price.toStringAsFixed(0);
      _stockController.text = product.stock.toString();
      _minStockController.text = product.minStock.toString();
      _selectedCategory = product.category;
    } else {
      _editingProductId = null;
      _skuController.clear();
      _nameController.clear();
      _priceController.clear();
      _stockController.clear();
      _minStockController.text = '10';
      _selectedCategory = 'Makanan';
    }

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
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product == null ? "Tambah Produk Baru" : "Edit Produk",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Form Fields
                  Row(
                    children: [
                      Expanded(child: _buildInput("SKU", _skuController)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Kategori",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              dropdownColor: AppColors.surface,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.background,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                              ),
                              items:
                                  [
                                    'Makanan',
                                    'Minuman',
                                    'Dapur',
                                    'Kebersihan',
                                  ].map((String val) {
                                    return DropdownMenuItem(
                                      value: val,
                                      child: Text(val),
                                    );
                                  }).toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedCategory = val!),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInput("Nama Produk", _nameController),
                  const SizedBox(height: 12),
                  _buildInput(
                    "Harga Jual (Rp)",
                    _priceController,
                    isNumber: true,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInput(
                          "Stok",
                          _stockController,
                          isNumber: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInput(
                          "Min. Stok",
                          _minStockController,
                          isNumber: true,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Tombol Simpan & Hapus (Jika Edit)
                  Row(
                    children: [
                      if (product != null)
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: OutlinedButton(
                              onPressed: () => _deleteProduct(product),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.danger,
                                side: const BorderSide(color: AppColors.danger),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Icon(Icons.delete_outline),
                            ),
                          ),
                        ),
                      Expanded(
                        flex: 3,
                        child: ElevatedButton(
                          onPressed: _saveProduct,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            product == null ? "Simpan Produk" : "Update Produk",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInput(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        if (_editingProductId != null) {
          // UPDATE Logic
          final index = dummyProducts.indexWhere(
            (p) => p.id == _editingProductId,
          );
          if (index != -1) {
            dummyProducts[index] = Product(
              id: _editingProductId!,
              name: _nameController.text,
              sku: _skuController.text,
              category: _selectedCategory,
              price: double.parse(_priceController.text),
              stock: int.parse(_stockController.text),
              minStock: int.parse(_minStockController.text),
            );
          }
        } else {
          // CREATE Logic
          dummyProducts.add(
            Product(
              id: DateTime.now().toString(),
              name: _nameController.text,
              sku: _skuController.text,
              category: _selectedCategory,
              price: double.parse(_priceController.text),
              stock: int.parse(_stockController.text),
              minStock: int.parse(_minStockController.text),
            ),
          );
        }
      });
      Navigator.pop(context);
    }
  }

  void _deleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text("Hapus Produk?"),
        content: Text(
          "Yakin ingin menghapus ${product.name}?",
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Batal",
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(
                () => dummyProducts.removeWhere((p) => p.id == product.id),
              );
              Navigator.pop(context); // Tutup Dialog
              Navigator.pop(context); // Tutup Modal Form
            },
            child: const Text(
              "Hapus",
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
