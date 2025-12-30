class StatItem {
  final String title;
  final String value;
  final String change;
  final String type;
  final String icon;

  StatItem(this.title, this.value, this.change, this.type, this.icon);
}

class Transaction {
  final String id;
  final String customerName;
  final String time;
  final double totalPrice;
  final List<TransactionItemDetail> items;

  Transaction(
    this.id,
    this.customerName,
    this.time,
    this.totalPrice,
    this.items,
  );

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.qty);
}

class TransactionItemDetail {
  final String name;
  final int qty;
  final double price;

  TransactionItemDetail({
    required this.name,
    required this.qty,
    required this.price,
  });
}

class Product {
  final String id;
  final String name;
  final String sku;
  final String category;
  final double price;
  int stock;
  final int minStock;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.price,
    required this.stock,
    required this.minStock,
  });
}

class Employee {
  final String id;
  final String name;
  final String role;
  final String status;
  final String phone;
  final String email;
  final String joinedAt;

  Employee({
    required this.id,
    required this.name,
    required this.role,
    required this.status,
    required this.phone,
    required this.email,
    required this.joinedAt,
  });
}

List<Employee> dummyEmployees = [
  Employee(
    id: '1',
    name: 'Siti Aminah',
    role: 'Kasir',
    status: 'active',
    phone: '081234567890',
    email: 'siti.aminah@tokoku.com',
    joinedAt: '2023-01-15',
  ),
  Employee(
    id: '2',
    name: 'Budi Santoso',
    role: 'Gudang',
    status: 'cuti',
    phone: '085678901234',
    email: 'budi.santoso@tokoku.com',
    joinedAt: '2023-03-10',
  ),
  Employee(
    id: '3',
    name: 'Rina Wati',
    role: 'Supervisor',
    status: 'active',
    phone: '081345678901',
    email: 'rina.wati@tokoku.com',
    joinedAt: '2022-11-05',
  ),
];

List<Product> dummyProducts = [
  Product(
    id: '1',
    name: 'Beras Pandan Wangi 5kg',
    sku: 'BRS001',
    category: 'Dapur',
    price: 72000,
    stock: 11,
    minStock: 5,
  ),
  Product(
    id: '2',
    name: 'Minyak Goreng Bimoli 1L',
    sku: 'MYK001',
    category: 'Dapur',
    price: 18500,
    stock: 1,
    minStock: 5,
  ),
  Product(
    id: '3',
    name: 'Gula Pasir Gulaku 1kg',
    sku: 'GUL001',
    category: 'Dapur',
    price: 16000,
    stock: 32,
    minStock: 10,
  ),
  Product(
    id: '4',
    name: 'Telur Ayam Negeri 1kg',
    sku: 'TLR001',
    category: 'Dapur',
    price: 28000,
    stock: 12,
    minStock: 5,
  ),
  Product(
    id: '5',
    name: 'Tepung Segitiga Biru 1kg',
    sku: 'TPG001',
    category: 'Dapur',
    price: 14000,
    stock: 24,
    minStock: 5,
  ),
  Product(
    id: '6',
    name: 'Kecap Bango Manis 550ml',
    sku: 'KCP001',
    category: 'Dapur',
    price: 22500,
    stock: 18,
    minStock: 5,
  ),
];

final List<StatItem> dummyStats = [
  StatItem('Total Pendapatan', 'Rp 2.5jt', '+12.5%', 'positive', 'wallet'),
  StatItem('Transaksi', '48', '+5%', 'positive', 'cart'),
  StatItem('Stok Rendah', '5 Item', '-2 Item', 'negative', 'package'),
  StatItem('Pelanggan', '120', '+8', 'positive', 'users'),
];

final List<Transaction> dummyTransactions = [
  Transaction('TRX-001', 'Pelanggan Umum', 'Hari ini, 09:40', 45000, [
    TransactionItemDetail(name: 'Indomie Goreng', qty: 5, price: 3500),
    TransactionItemDetail(name: 'Minyak Goreng 1L', qty: 1, price: 14000),
    TransactionItemDetail(
      name: 'Teh Pucuk Harum',
      qty: 2,
      price: 4000,
    ), // Total 17.5 + 14 + 8 = 39.5 (Anggap ada pajak/pembulatan di contoh ini, kita set manual 45rb biar gampang)
  ]),
  Transaction('TRX-002', 'Budi Santoso', 'Hari ini, 08:15', 12000, [
    TransactionItemDetail(name: 'Kopi Kapal Api', qty: 2, price: 1500),
    TransactionItemDetail(name: 'Roti Tawar', qty: 1, price: 9000),
  ]),
  Transaction('TRX-003', 'Siti Aminah', 'Kemarin, 16:20', 125000, [
    TransactionItemDetail(name: 'Beras 5kg', qty: 1, price: 65000),
    TransactionItemDetail(name: 'Telur 1kg', qty: 1, price: 28000),
    TransactionItemDetail(name: 'Minyak Goreng 2L', qty: 1, price: 32000),
  ]),
];

// ... kode sebelumnya ...

// DATA DUMMY UNTUK GRAFIK ANALITIK
class MonthlySales {
  final String month;
  final double amount;

  MonthlySales(this.month, this.amount);
}

final List<MonthlySales> dummyMonthlySales = [
  MonthlySales('Jan', 15000000),
  MonthlySales('Feb', 18500000),
  MonthlySales('Mar', 12000000),
  MonthlySales('Apr', 22000000),
  MonthlySales('Mei', 25000000), // Tertinggi
  MonthlySales('Jun', 21500000),
];

// DATA DUMMY PRODUK TERLARIS
class TopProduct {
  final String name;
  final int sold;
  final double revenue;

  TopProduct(this.name, this.sold, this.revenue);
}

final List<TopProduct> dummyTopProducts = [
  TopProduct('Beras Pandan Wangi 5kg', 120, 8640000),
  TopProduct('Minyak Goreng Bimoli 1L', 85, 1572500),
  TopProduct('Telur Ayam Negeri 1kg', 60, 1680000),
  TopProduct('Gula Pasir Gulaku 1kg', 45, 720000),
];
