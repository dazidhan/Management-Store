import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_coba/screens/kasir_screen.dart';
import '../theme/app_theme.dart';
import '../services/database_service.dart';
import 'package:intl/intl.dart';
import 'analitik_screen.dart';
import 'laporan_screen.dart';
import 'barcode_scanner_screen.dart';
import 'setup_store_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final databaseService = DatabaseService();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting & Store Name (Dynamic from Firestore)
          const Text(
            "Selamat Pagi 👋",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 4),
          
          // StreamBuilder untuk Store Profile
          StreamBuilder<DocumentSnapshot>(
            stream: databaseService.getStoreProfile(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text(
                  "Loading...",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }

              if (snapshot.hasError) {
                return const Text(
                  "Error",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }

              // Jika store profile tidak ada atau kosong
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return _buildSetupStoreCard(context);
              }

              // Tampilkan nama toko dari Firestore
              final storeData = snapshot.data!.data() as Map<String, dynamic>?;
              final storeName = storeData?['storeName'] as String? ?? 'Toko Saya';

              return Text(
                storeName,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Stats Grid (TODO: Make dynamic from Firestore)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              // Placeholder stats - will be made dynamic later
              return _buildStatCard(index);
            },
          ),
          const SizedBox(height: 24),

          // Aksi Cepat
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
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const KasirScreen(),
                    ),
                  );
                },
              ),
              _buildQuickAction(
                Icons.qr_code_scanner,
                "Scan",
                AppColors.info,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BarcodeScannerScreen(),
                    ),
                  );
                },
              ),
              _buildQuickAction(
                Icons.assignment,
                "Laporan",
                AppColors.warning,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LaporanScreen(),
                    ),
                  );
                },
              ),
              _buildQuickAction(
                Icons.bar_chart,
                "Analitik",
                AppColors.success,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AnalitikScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Transaksi Terakhir (Dynamic from Firestore)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Transaksi Terakhir",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  "Lihat Semua",
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
          StreamBuilder<QuerySnapshot>(
            stream: databaseService.getTransactions(),
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
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text(
                      'Belum ada transaksi',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                );
              }

              final transactions = snapshot.data!.docs.take(5).toList();

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  final data = transaction.data() as Map<String, dynamic>;
                  return _buildTransactionItem(context, transaction.id, data);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSetupStoreCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SetupStoreScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.store,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Setup Toko Kamu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Klik untuk mengatur nama dan alamat toko',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(int index) {
    final stats = [
      {'title': 'Total Pendapatan', 'value': 'Rp 0', 'icon': Icons.account_balance_wallet, 'color': AppColors.info},
      {'title': 'Transaksi', 'value': '0', 'icon': Icons.shopping_cart, 'color': AppColors.primary},
      {'title': 'Stok Rendah', 'value': '0 Item', 'icon': Icons.inventory_2, 'color': AppColors.warning},
      {'title': 'Pelanggan', 'value': '0', 'icon': Icons.group, 'color': AppColors.success},
    ];

    final stat = stats[index];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stat['title'] as String,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stat['value'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: (stat['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(stat['icon'] as IconData, color: stat['color'] as Color, size: 18),
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

  Widget _buildTransactionItem(BuildContext context, String transactionId, Map<String, dynamic> data) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final customerName = data['customerName'] as String? ?? 'Pelanggan Umum';
    final totalPrice = (data['totalPrice'] as num?)?.toDouble() ?? 0.0;
    final items = data['items'] as List<dynamic>? ?? [];
    final totalItems = items.fold<int>(0, (sum, item) => sum + ((item as Map)['qty'] as int? ?? 0));
    
    // Format timestamp
    String timeStr = 'Hari ini';
    if (data['createdAt'] != null) {
      final timestamp = data['createdAt'] as Timestamp;
      final date = timestamp.toDate();
      final now = DateTime.now();
      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        timeStr = 'Hari ini, ${DateFormat('HH:mm').format(date)}';
      } else {
        timeStr = DateFormat('dd MMM, HH:mm').format(date);
      }
    }

    return InkWell(
      onTap: () {
        // Navigate to transaction detail
        // TODO: Create transaction detail from Firestore data
      },
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.receipt_long,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customerName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    "$totalItems item • $timeStr",
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
                  currencyFormat.format(totalPrice),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
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
