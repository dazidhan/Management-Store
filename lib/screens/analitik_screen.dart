import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../services/database_service.dart';

class AnalitikScreen extends StatelessWidget {
  const AnalitikScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dbService = DatabaseService();

    return Scaffold(
      appBar: AppBar(title: const Text("Analitik Toko"), centerTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: dbService.getTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final docs = snapshot.data?.docs ?? [];

          double totalRevenue = 0;
          int totalTrx = docs.length;

          final Map<int, double> monthlyData = {};
          final now = DateTime.now();

          for (int i = 5; i >= 0; i--) {
            final d = DateTime(now.year, now.month - i, 1);
            monthlyData[d.month] = 0.0;
          }

          final Map<String, Map<String, dynamic>> productStats = {};

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final price = (data['totalPrice'] as num?)?.toDouble() ?? 0.0;

            totalRevenue += price;

            if (data['createdAt'] != null) {
              final date = (data['createdAt'] as Timestamp).toDate();
              final sixMonthsAgo = DateTime(now.year, now.month - 6, 1);
              if (date.isAfter(sixMonthsAgo)) {
                monthlyData[date.month] =
                    (monthlyData[date.month] ?? 0) + price;
              }
            }

            final items = data['items'] as List<dynamic>? ?? [];
            for (var item in items) {
              final name = item['name'] as String? ?? 'Produk';
              final qty = item['qty'] as int? ?? 0;
              final itemPrice = (item['price'] as num?)?.toDouble() ?? 0.0;
              final revenue = qty * itemPrice;

              if (productStats.containsKey(name)) {
                productStats[name]!['qty'] += qty;
                productStats[name]!['revenue'] += revenue;
              } else {
                productStats[name] = {'qty': qty, 'revenue': revenue};
              }
            }
          }

          final topProducts = productStats.entries.toList()
            ..sort((a, b) => b.value['qty'].compareTo(a.value['qty']));
          final top5Products = topProducts.take(5).toList();

          double maxChartVal = 0;
          monthlyData.forEach((k, v) {
            if (v > maxChartVal) maxChartVal = v;
          });
          if (maxChartVal == 0) maxChartVal = 1;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Ringkasan Total",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        "Omzet Kotor",
                        currencyFormat.format(totalRevenue),
                        "Live",
                        AppColors.primary,
                        Icons.attach_money,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        "Profit (Est 20%)",
                        currencyFormat.format(totalRevenue * 0.2),
                        "Est",
                        AppColors.info,
                        Icons.pie_chart,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        "Total Transaksi",
                        "$totalTrx",
                        "Live",
                        AppColors.warning,
                        Icons.receipt,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        "Rata-rata Order",
                        totalTrx == 0
                            ? "0"
                            : currencyFormat.format(totalRevenue / totalTrx),
                        "Avg",
                        AppColors.success,
                        Icons.analytics,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Tren Penjualan",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                "6 Bulan Terakhir",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        height: 150,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: monthlyData.entries.map((entry) {
                            final monthName = DateFormat(
                              'MMM',
                            ).format(DateTime(2024, entry.key, 1));
                            final heightPct = entry.value / maxChartVal;

                            return _buildBarItem(
                              monthName,
                              heightPct,
                              entry.value == maxChartVal && entry.value > 0,
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                const Text(
                  "Produk Terlaris",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                if (top5Products.isEmpty)
                  const Text(
                    "Belum ada data penjualan produk.",
                    style: TextStyle(color: AppColors.textSecondary),
                  ),

                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: top5Products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final entry = top5Products[index];
                    final name = entry.key;
                    final qty = entry.value['qty'];
                    final revenue = entry.value['revenue'];

                    return Container(
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
                            child: Center(
                              child: Text(
                                "#${index + 1}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
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
                                  "$qty terjual",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            currencyFormat.format(revenue),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    String percent,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Text(
                percent,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarItem(String label, double heightPercent, bool isMax) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 30,
          height: 120 * heightPercent,
          decoration: BoxDecoration(
            color: isMax ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(8),
            gradient: isMax
                ? const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF059669)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isMax ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isMax ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
