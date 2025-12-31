import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/database_service.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  String _searchQuery = '';
  final _databaseService = DatabaseService();

  final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header & Search
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        StreamBuilder<QuerySnapshot>(
                          stream: _databaseService.getProducts(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final count = snapshot.data!.docs.length;
                              return Text(
                                "$count produk",
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              );
                            }
                            return const Text(
                              "0 produk",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    InkWell(
                      // PANGGIL FORM PRODUK
                      onTap: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: AppColors.surface,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        builder: (context) => const ProductFormSheet(),
                      ),
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
              ],
            ),
          ),

          // Product List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _databaseService.getProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                final allProducts = snapshot.data!.docs;
                final filteredProducts = allProducts.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] as String? ?? '').toLowerCase();
                  final sku = (data['sku'] as String? ?? '').toLowerCase();
                  final query = _searchQuery.toLowerCase();
                  return name.contains(query) || sku.contains(query);
                }).toList();

                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ada produk yang cocok',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  itemCount: filteredProducts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final doc = filteredProducts[index];
                    return _buildStockCard(
                      doc.id,
                      doc.data() as Map<String, dynamic>,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada barang',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: AppColors.surface,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              builder: (context) => const ProductFormSheet(),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Tambah Barang'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockCard(String productId, Map<String, dynamic> data) {
    final name = data['name'] ?? '';
    final sku = data['sku'] ?? '';
    final category = data['category'] ?? '';
    final price = (data['price'] as num?)?.toDouble() ?? 0.0;
    final stock = (data['stock'] as num?)?.toInt() ?? 0;
    final minStock = (data['minStock'] as num?)?.toInt() ?? 0;
    final isLowStock = stock <= minStock;

    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) =>
            ProductFormSheet(productId: productId, productData: data),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _getCategoryIcon(category),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 12),
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
                  ),
                  Text(
                    "SKU: $sku • $category",
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    _currencyFormat.format(price),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "$stock",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isLowStock
                        ? AppColors.danger
                        : AppColors.textPrimary,
                  ),
                ),
                Text(
                  "Min: $minStock",
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
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
    if (category == 'Dapur') return '🍳';
    if (category == 'Kebersihan') return '🧹';
    return '📦';
  }
}

// =========================================================
// WIDGET: FORM PRODUK (DENGAN KATEGORI CUSTOM)
// =========================================================
class ProductFormSheet extends StatefulWidget {
  final String? productId;
  final Map<String, dynamic>? productData;
  final String? initialBarcode;

  const ProductFormSheet({
    super.key,
    this.productId,
    this.productData,
    this.initialBarcode,
  });

  @override
  State<ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<ProductFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _databaseService = DatabaseService();

  final _skuController = TextEditingController();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _minStockController = TextEditingController(text: '10');
  final _barcodeController = TextEditingController();
  String _selectedCategory = 'Makanan'; // Default awal

  @override
  void initState() {
    super.initState();
    if (widget.productData != null) {
      final data = widget.productData!;
      _skuController.text = data['sku'] ?? '';
      _nameController.text = data['name'] ?? '';
      _priceController.text = (data['price'] as num?)?.toString() ?? '';
      _stockController.text = (data['stock'] as num?)?.toString() ?? '';
      _minStockController.text = (data['minStock'] as num?)?.toString() ?? '10';
      _barcodeController.text = data['barcode'] ?? '';
      _selectedCategory = data['category'] ?? 'Makanan';
    } else if (widget.initialBarcode != null) {
      _barcodeController.text = widget.initialBarcode!;
      _skuController.text = widget.initialBarcode!;
    }
  }

  // Helper untuk menambah kategori baru
  void _showAddCategoryDialog() {
    final catController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tambah Kategori Baru"),
        content: TextField(
          controller: catController,
          decoration: const InputDecoration(
            hintText: "Contoh: Elektronik, Obat, dll",
            filled: true,
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              final newCat = catController.text.trim();
              if (newCat.isNotEmpty) {
                // Simpan ke Firebase
                await _databaseService.addCategory(newCat);
                // Set sebagai selected
                setState(() => _selectedCategory = newCat);
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text("Tambah", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    widget.productId == null ? "Tambah Produk" : "Edit Produk",
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
              // Form Inputs
              _buildInput("Nama Produk", _nameController),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildInput("SKU", _skuController)),
                  const SizedBox(width: 12),
                  Expanded(
                    // --- KATEGORI DINAMIS ---
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Kategori",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            // Tombol Tambah Kategori Kecil
                            InkWell(
                              onTap: _showAddCategoryDialog,
                              child: const Padding(
                                padding: EdgeInsets.only(bottom: 2.0),
                                child: Text(
                                  "+ Tambah",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // StreamBuilder untuk membaca kategori dari Firebase
                        StreamBuilder<QuerySnapshot>(
                          stream: _databaseService.getCategories(),
                          builder: (context, snapshot) {
                            // Daftar default
                            Set<String> categories = {
                              'Makanan',
                              'Minuman',
                              'Dapur',
                              'Kebersihan',
                            };

                            // Tambahkan dari Firebase jika ada
                            if (snapshot.hasData) {
                              for (var doc in snapshot.data!.docs) {
                                final data = doc.data() as Map<String, dynamic>;
                                if (data['name'] != null) {
                                  categories.add(data['name']);
                                }
                              }
                            }

                            // Pastikan kategori yang sedang dipilih ada di list (jika data lama)
                            categories.add(_selectedCategory);

                            return DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              isExpanded: true, // Agar teks panjang tidak error
                              dropdownColor: AppColors.surface,
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
                              items: categories.map((val) {
                                return DropdownMenuItem(
                                  value: val,
                                  child: Text(
                                    val,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedCategory = val!),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInput(
                      "Harga (Rp)",
                      _priceController,
                      isNumber: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInput("Barcode", _barcodeController)),
                ],
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

              // BUTTONS
              Row(
                children: [
                  if (widget.productId != null)
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: OutlinedButton(
                          onPressed: () => _deleteProduct(widget.productId!),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.danger,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Icon(Icons.delete),
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
                      ),
                      child: Text(
                        widget.productId == null ? "Simpan" : "Update",
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
          validator: (val) => (val!.isEmpty && !label.contains("Barcode"))
              ? "Wajib diisi"
              : null,
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
          ),
        ),
      ],
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final price =
        double.tryParse(
          _priceController.text.replaceAll(RegExp(r'[^0-9.]'), ''),
        ) ??
        0.0;
    final stock =
        int.tryParse(_stockController.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
        0;
    final minStock =
        int.tryParse(
          _minStockController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;

    final productData = {
      'sku': _skuController.text.trim(),
      'name': _nameController.text.trim(),
      'category': _selectedCategory,
      'price': price,
      'stock': stock,
      'minStock': minStock,
      'barcode': _barcodeController.text.trim().isEmpty
          ? null
          : _barcodeController.text.trim(),
    };

    Navigator.pop(context); // Close Modal

    try {
      if (widget.productId != null) {
        await _databaseService.updateProduct(widget.productId!, productData);
      } else {
        await _databaseService.addProduct(productData);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil disimpan'),
            backgroundColor: AppColors.accent,
            behavior: SnackBarBehavior.floating,
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

  Future<void> _deleteProduct(String productId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Produk?"),
        content: const Text("Yakin ingin menghapus produk ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Hapus",
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (mounted) Navigator.pop(context); // Close Modal
      try {
        await _databaseService.deleteProduct(productId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Produk dihapus'),
              backgroundColor: AppColors.accent,
            ),
          );
        }
      } catch (e) {
        // Error handling
      }
    }
  }
}
