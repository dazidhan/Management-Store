import 'package:flutter/material.dart';
import 'package:project_coba/screens/kasir_screen.dart';
import '../theme/app_theme.dart';
import '../models/dummy_data.dart';
import 'package:intl/intl.dart'; // Tambahkan ini
import 'transaction_detail_screen.dart'; // Tambahkan ini
import 'analitik_screen.dart'; // <-- Tambahkan
import 'laporan_screen.dart'; // <-- Tambahkan

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Install Banner (Opsional, kita buat UI-nya saja)

          // 2. Greeting
          const Text(
            "Selamat Pagi 👋",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 4),
          const Text(
            "Ahmad Store",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // 3. Stats Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemCount: dummyStats.length,
            itemBuilder: (context, index) {
              return _buildStatCard(dummyStats[index]);
            },
          ),
          const SizedBox(height: 24),

          // 4. Aksi Cepat
          const Text(
            "Aksi Cepat",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          // ... di dalam Column/Row Aksi Cepat ...
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
                () {},
              ),

              // --- UBAH BAGIAN INI ---
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

              // --- DAN BAGIAN INI ---
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

          // 5. Transaksi Terakhir
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
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dummyTransactions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              // Kirim context agar bisa melakukan Navigator.push
              return _buildTransactionItem(context, dummyTransactions[index]);
            },
          ),
        ],
      ),
    );
  }

  // --- Widgets Components ---

  Widget _buildStatCard(StatItem stat) {
    Color iconBgColor;
    Color iconColor;
    IconData iconData;

    switch (stat.icon) {
      case 'wallet':
        iconBgColor = AppColors.info.withOpacity(0.1);
        iconColor = AppColors.info;
        iconData = Icons.account_balance_wallet;
        break;
      case 'cart':
        iconBgColor = AppColors.primary.withOpacity(0.1);
        iconColor = AppColors.primary;
        iconData = Icons.shopping_cart;
        break;
      case 'package':
        iconBgColor = AppColors.warning.withOpacity(0.1);
        iconColor = AppColors.warning;
        iconData = Icons.inventory_2;
        break;
      default:
        iconBgColor = AppColors.success.withOpacity(0.1);
        iconColor = AppColors.success;
        iconData = Icons.group;
    }

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
                    stat.title,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stat.value,
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
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(iconData, color: iconColor, size: 18),
              ),
            ],
          ),
          Text(
            stat.change,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: stat.type == 'positive'
                  ? AppColors.success
                  : AppColors.danger,
            ),
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
            width: 56, // Fixed size to match grid look
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

  Widget _buildTransactionItem(BuildContext context, Transaction trx) {
    // Format rupiah di dashboard
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return InkWell(
      // <-- Tambahkan InkWell agar bisa diklik
      onTap: () {
        // Navigasi ke Halaman Detail
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionDetailScreen(transaction: trx),
          ),
        );
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
                    trx.customerName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  // Mengambil total item dari getter yang kita buat di model
                  Text(
                    "${trx.totalItemCount} item • ${trx.time}",
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
                  currencyFormat.format(trx.totalPrice),
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
