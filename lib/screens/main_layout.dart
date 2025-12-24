import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'kasir_screen.dart';
import 'stock_screen.dart';
import 'karyawan_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardScreen(),
    const KasirScreen(),
    const StockScreen(),
    const KaryawanScreen(),
  ];

  // Fungsi untuk menampilkan Dialog Konfirmasi Logout
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Konfirmasi",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Keluar dari aplikasi?",
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Tutup dialog
            child: const Text(
              "Batal",
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              // LOGIC LOGOUT DISINI
              // Contoh: Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Berhasil Logout (Simulasi)"),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text(
              "Keluar",
              style: TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar hanya muncul di halaman Dashboard (Index 0)
      appBar: _selectedIndex == 0
          ? AppBar(
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.store,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text("TokoKu", style: TextStyle(fontSize: 18)),
                ],
              ),
              actions: [
                // TOMBOL LOGOUT
                IconButton(
                  onPressed: _showLogoutDialog, // Panggil fungsi dialog
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.textSecondary,
                  ),
                  tooltip: 'Keluar',
                ),
                const SizedBox(width: 8),
              ],
            )
          : null,

      body: SafeArea(child: _pages[_selectedIndex]),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.point_of_sale),
              label: 'Kasir',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2),
              label: 'Stok',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Karyawan',
            ),
          ],
        ),
      ),
    );
  }
}
