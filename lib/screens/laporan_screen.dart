import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/dummy_data.dart';
import 'transaction_detail_screen.dart'; // Agar bisa klik detail transaksi

class LaporanScreen extends StatelessWidget {
  const LaporanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Jumlah Tab
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Pusat Laporan"),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            dividerColor: Colors.transparent,
            tabs: [
              Tab(text: "Transaksi"),
              Tab(text: "Laba Rugi"),
              Tab(text: "Keluar Masuk"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _TransactionReportTab(),
            _ProfitLossTab(), // Placeholder simulasi
            _StockHistoryTab(), // Placeholder simulasi
          ],
        ),
      ),
    );
  }
}

// --- TAB 1: LAPORAN TRANSAKSI (Menggunakan Data Dummy) ---
class _TransactionReportTab extends StatelessWidget {
  const _TransactionReportTab();

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dummyTransactions.length,
      itemBuilder: (context, index) {
        final trx = dummyTransactions[index];
        return Card(
          // Menggunakan Card bawaan Flutter sedikit dimodifikasi
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border),
          ),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TransactionDetailScreen(transaction: trx),
                ),
              );
            },
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.receipt_long, color: AppColors.primary),
            ),
            title: Text(
              trx.customerName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  trx.id,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  trx.time,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormat.format(trx.totalPrice),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "Sukses",
                    style: TextStyle(color: AppColors.success, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// --- TAB 2: LABA RUGI (Tampilan Statis) ---
class _ProfitLossTab extends StatelessWidget {
  const _ProfitLossTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            "Laporan Laba Rugi",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text(
            "Fitur ini membutuhkan data real transaksi.",
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// --- TAB 3: RIWAYAT STOK (Tampilan Statis) ---
class _StockHistoryTab extends StatelessWidget {
  const _StockHistoryTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildLogItem(
          "Beras Pandan Wangi",
          "Restock Suplier",
          "+50",
          "Hari ini, 10:00",
          true,
        ),
        _buildLogItem(
          "Minyak Goreng",
          "Penjualan TRX-001",
          "-1",
          "Hari ini, 09:40",
          false,
        ),
        _buildLogItem(
          "Gula Pasir",
          "Barang Rusak/Expired",
          "-2",
          "Kemarin, 17:00",
          false,
        ),
        _buildLogItem(
          "Telur Ayam",
          "Restock Suplier",
          "+100",
          "Kemarin, 08:00",
          true,
        ),
      ],
    );
  }

  Widget _buildLogItem(
    String name,
    String reason,
    String change,
    String time,
    bool isIn,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isIn
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.danger.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isIn ? Icons.arrow_downward : Icons.arrow_upward,
              color: isIn ? AppColors.success : AppColors.danger,
              size: 20,
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
                  ),
                ),
                Text(
                  reason,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                change,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isIn ? AppColors.success : AppColors.danger,
                  fontSize: 16,
                ),
              ),
              Text(
                time,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
