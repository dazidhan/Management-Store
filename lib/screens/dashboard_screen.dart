import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/database_service.dart';
import '../screens/kasir_screen.dart';
import '../screens/analitik_screen.dart';
import '../screens/laporan_screen.dart';
import '../screens/barcode_scanner_screen.dart';
import '../screens/setup_store_screen.dart';
import '../screens/Transaction_detail_screen.dart';
import '../screens/stock_screen.dart'; // IMPORT INI PENTING (Untuk Akses ProductFormSheet)

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _databaseService = DatabaseService();
  final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi ☀️';
    if (hour < 15) return 'Selamat Siang 🌤️';
    if (hour < 18) return 'Selamat Sore 🌇';
    return 'Selamat Malam 🌙';
  }

  // --- LOGIC: SCAN BARCODE ---
  Future<void> _handleScanAction() async {
    final barcode = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );

    if (barcode != null && barcode is String && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mencari data..."),
          duration: Duration(seconds: 1),
        ),
      );

      try {
        final productDoc = await _databaseService.getProductByBarcode(barcode);
        if (!mounted) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        if (productDoc != null && productDoc.exists) {
          final data = productDoc.data() as Map<String, dynamic>;
          _showProductDetailDialog(data, productDoc.id);
        } else {
          // JIKA TIDAK KETEMU -> Buka Dialog Not Found
          _showNotFoundDialog(barcode);
        }
      } catch (e) {
        // Handle Error
      }
    }
  }

  void _showProductDetailDialog(Map<String, dynamic> data, String docId) {
    final name = data['name'] ?? 'Tanpa Nama';
    final sku = data['sku'] ?? '-';
    final price = (data['price'] as num?)?.toDouble() ?? 0;
    final stock = (data['stock'] as num?)?.toInt() ?? 0;
    final minStock = (data['minStock'] as num?)?.toInt() ?? 0;
    final isLow = stock <= minStock;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.inventory_2_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "SKU: $sku",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        const Text(
                          "Harga Jual",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currencyFormat.format(price),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Container(width: 1, height: 40, color: AppColors.border),
                    Column(
                      children: [
                        const Text(
                          "Sisa Stok",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$stock",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isLow
                                ? AppColors.warning
                                : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Tutup",
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showNotFoundDialog(String barcode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.warning),
            SizedBox(width: 10),
            Text("Produk Baru?"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Barcode ini belum terdaftar."),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                barcode,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context); // Tutup Dialog dulu

              // Buka Form Tambah Produk (Dari StockScreen)
              // Kita kirim barcode agar form otomatis terisi
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: AppColors.surface,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (context) => ProductFormSheet(initialBarcode: barcode),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text("Tambah Produk"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getGreeting(),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),

          StreamBuilder<DocumentSnapshot>(
            stream: _databaseService.getStoreProfile(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  height: 30,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }
              if (snapshot.hasData &&
                  snapshot.data != null &&
                  snapshot.data!.exists) {
                final storeData =
                    snapshot.data!.data() as Map<String, dynamic>?;
                final storeName = storeData?['storeName'] as String?;
                if (storeName != null && storeName.isNotEmpty) {
                  return Text(
                    storeName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
              }
              return _buildSetupStoreCard(context);
            },
          ),

          const SizedBox(height: 24),

          // Stats Grid & Others (Sama seperti sebelumnya, dipersingkat untuk fokus)
          // ... (Bagian ini tidak berubah dari kode sebelumnya)
          StreamBuilder<QuerySnapshot>(
            stream: _databaseService.getTransactions(),
            builder: (context, trxSnapshot) {
              // ... Logic Stats ...
              double totalRevenue = 0;
              int totalTrx = 0;
              if (trxSnapshot.hasData) {
                for (var doc in trxSnapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  totalRevenue +=
                      (data['totalPrice'] as num?)?.toDouble() ?? 0.0;
                }
                totalTrx = trxSnapshot.data!.docs.length;
              }

              return StreamBuilder<QuerySnapshot>(
                stream: _databaseService.getProducts(),
                builder: (context, prodSnapshot) {
                  int lowStock = 0;
                  if (prodSnapshot.hasData) {
                    lowStock = prodSnapshot.data!.docs.where((doc) {
                      final d = doc.data() as Map<String, dynamic>;
                      return (d['stock'] ?? 0) <= (d['min_stock'] ?? 5);
                    }).length;
                  }

                  final stats = [
                    {
                      'title': 'Pendapatan',
                      'value': _currencyFormat.format(totalRevenue),
                      'icon': Icons.account_balance_wallet,
                      'color': AppColors.info,
                    },
                    {
                      'title': 'Transaksi',
                      'value': '$totalTrx',
                      'icon': Icons.shopping_cart,
                      'color': AppColors.primary,
                    },
                    {
                      'title': 'Stok Rendah',
                      'value': '$lowStock Item',
                      'icon': Icons.inventory_2,
                      'color': AppColors.warning,
                    },
                    {
                      'title': 'Pelanggan',
                      'value': '$totalTrx',
                      'icon': Icons.group,
                      'color': AppColors.success,
                    },
                  ];

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.6,
                        ),
                    itemCount: stats.length,
                    itemBuilder: (context, index) =>
                        _buildStatCard(stats[index]),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 24),
          const Text(
            "Aksi Cepat",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildQuickAction(
                Icons.swap_horiz,
                "Transaksi",
                AppColors.primary,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const KasirScreen()),
                ),
              ),
              _buildQuickAction(
                Icons.qr_code_scanner,
                "Cek Info",
                AppColors.info,
                _handleScanAction,
              ),
              _buildQuickAction(
                Icons.assignment,
                "Laporan",
                AppColors.warning,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LaporanScreen()),
                ),
              ),
              _buildQuickAction(
                Icons.bar_chart,
                "Analitik",
                AppColors.success,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AnalitikScreen()),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          // ... Transaksi Terakhir (Kode sama) ...
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Transaksi Terakhir",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LaporanScreen()),
                ),
                child: const Text(
                  "Lihat Semua",
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
          StreamBuilder<QuerySnapshot>(
            stream: _databaseService.getTransactions(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                return const SizedBox();
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.take(5).length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) => _buildTransactionItem(
                  context,
                  snapshot.data!.docs[i].id,
                  snapshot.data!.docs[i].data() as Map<String, dynamic>,
                ),
              );
            },
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // --- WIDGET HELPERS (Copied from previous code for completeness) ---
  Widget _buildSetupStoreCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SetupStoreScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.store_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Lengkapi Profil Toko",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Agar nama toko muncul di struk",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stat['title'],
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stat['value'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: (stat['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(stat['icon'], color: stat['color'], size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    String id,
    Map<String, dynamic> data,
  ) {
    // ... Logic sama seperti sebelumnya ...
    // Saya persingkat agar tidak terlalu panjang, tapi pastikan logic date parsing tetap ada
    final total = (data['totalPrice'] as num?)?.toDouble() ?? 0.0;
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    DateTime date = (data['createdAt'] == null)
        ? DateTime.now()
        : (data['createdAt'] is Timestamp
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now());

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              TransactionDetailScreen(transactionId: id, transactionData: data),
        ),
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.receipt_long,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['customerName'] ?? 'Pelanggan Umum',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    DateFormat('dd MMM, HH:mm').format(date),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currency.format(total),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "Selesai",
                    style: TextStyle(fontSize: 9, color: AppColors.success),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
