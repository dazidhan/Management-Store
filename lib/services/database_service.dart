import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get user document reference
  DocumentReference? get _userDoc {
    final uid = currentUserId;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid);
  }

  // ========== STORE MANAGEMENT ==========
  
  // Get store profile document reference
  DocumentReference? get _storeProfileDoc {
    final userDoc = _userDoc;
    if (userDoc == null) return null;
    return userDoc.collection('store_profile').doc('profile');
  }

  // Get store profile stream
  Stream<DocumentSnapshot>? getStoreProfile() {
    return _storeProfileDoc?.snapshots();
  }

  // Get store profile data (one-time)
  Future<Map<String, dynamic>?> getStoreProfileData() async {
    final storeDoc = _storeProfileDoc;
    if (storeDoc == null) return null;

    try {
      final doc = await storeDoc.get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      throw 'Gagal mengambil data toko: ${e.toString()}';
    }
  }

  // Create or update store profile
  Future<void> setStoreProfile({
    required String storeName,
    required String address,
  }) async {
    final storeDoc = _storeProfileDoc;
    if (storeDoc == null) throw 'User tidak terautentikasi';

    try {
      await storeDoc.set({
        'storeName': storeName,
        'address': address,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw 'Gagal menyimpan data toko: ${e.toString()}';
    }
  }

  // ========== PRODUCTS ==========

  // Get products collection reference
  CollectionReference? get _productsCollection {
    final userDoc = _userDoc;
    if (userDoc == null) return null;
    return userDoc.collection('products');
  }

  // Get all products
  Stream<QuerySnapshot>? getProducts() {
    return _productsCollection?.orderBy('name').snapshots();
  }

  // Get product by ID
  Future<DocumentSnapshot?> getProduct(String productId) async {
    try {
      return await _productsCollection?.doc(productId).get();
    } catch (e) {
      throw 'Gagal mengambil produk: ${e.toString()}';
    }
  }

  // Get product by barcode
  Future<DocumentSnapshot?> getProductByBarcode(String barcode) async {
    try {
      final query = await _productsCollection
          ?.where('barcode', isEqualTo: barcode)
          .limit(1)
          .get();
      if (query != null && query.docs.isNotEmpty) {
        return query.docs.first;
      }
      return null;
    } catch (e) {
      throw 'Gagal mencari produk: ${e.toString()}';
    }
  }

  // Add product
  Future<String> addProduct(Map<String, dynamic> productData) async {
    final productsCollection = _productsCollection;
    if (productsCollection == null) throw 'User tidak terautentikasi';

    try {
      final docRef = await productsCollection.add({
        ...productData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw 'Gagal menambahkan produk: ${e.toString()}';
    }
  }

  // Update product
  Future<void> updateProduct(String productId, Map<String, dynamic> productData) async {
    final productsCollection = _productsCollection;
    if (productsCollection == null) throw 'User tidak terautentikasi';

    try {
      await productsCollection.doc(productId).update({
        ...productData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Gagal memperbarui produk: ${e.toString()}';
    }
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    final productsCollection = _productsCollection;
    if (productsCollection == null) throw 'User tidak terautentikasi';

    try {
      await productsCollection.doc(productId).delete();
    } catch (e) {
      throw 'Gagal menghapus produk: ${e.toString()}';
    }
  }

  // ========== TRANSACTIONS ==========

  // Get transactions collection reference
  CollectionReference? get _transactionsCollection {
    final userDoc = _userDoc;
    if (userDoc == null) return null;
    return userDoc.collection('transactions');
  }

  // Get all transactions
  Stream<QuerySnapshot>? getTransactions() {
    return _transactionsCollection?.orderBy('createdAt', descending: true).snapshots();
  }

  // Get transactions by date range
  Stream<QuerySnapshot>? getTransactionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _transactionsCollection
        ?.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get transaction by ID
  Future<DocumentSnapshot?> getTransaction(String transactionId) async {
    try {
      return await _transactionsCollection?.doc(transactionId).get();
    } catch (e) {
      throw 'Gagal mengambil transaksi: ${e.toString()}';
    }
  }

  // Add transaction
  Future<String> addTransaction(Map<String, dynamic> transactionData) async {
    final transactionsCollection = _transactionsCollection;
    if (transactionsCollection == null) throw 'User tidak terautentikasi';

    try {
      final docRef = await transactionsCollection.add({
        ...transactionData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw 'Gagal menambahkan transaksi: ${e.toString()}';
    }
  }

  // Update transaction
  Future<void> updateTransaction(String transactionId, Map<String, dynamic> transactionData) async {
    final transactionsCollection = _transactionsCollection;
    if (transactionsCollection == null) throw 'User tidak terautentikasi';

    try {
      await transactionsCollection.doc(transactionId).update({
        ...transactionData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Gagal memperbarui transaksi: ${e.toString()}';
    }
  }

  // Delete transaction
  Future<void> deleteTransaction(String transactionId) async {
    final transactionsCollection = _transactionsCollection;
    if (transactionsCollection == null) throw 'User tidak terautentikasi';

    try {
      await transactionsCollection.doc(transactionId).delete();
    } catch (e) {
      throw 'Gagal menghapus transaksi: ${e.toString()}';
    }
  }

  // ========== EMPLOYEES ==========

  // Get employees collection reference
  CollectionReference? get _employeesCollection {
    final userDoc = _userDoc;
    if (userDoc == null) return null;
    return userDoc.collection('employees');
  }

  // Get all employees
  Stream<QuerySnapshot>? getEmployees() {
    return _employeesCollection?.orderBy('name').snapshots();
  }

  // Add employee
  Future<String> addEmployee(Map<String, dynamic> employeeData) async {
    final employeesCollection = _employeesCollection;
    if (employeesCollection == null) throw 'User tidak terautentikasi';

    try {
      final docRef = await employeesCollection.add({
        ...employeeData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw 'Gagal menambahkan karyawan: ${e.toString()}';
    }
  }

  // Update employee
  Future<void> updateEmployee(String employeeId, Map<String, dynamic> employeeData) async {
    final employeesCollection = _employeesCollection;
    if (employeesCollection == null) throw 'User tidak terautentikasi';

    try {
      await employeesCollection.doc(employeeId).update({
        ...employeeData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Gagal memperbarui karyawan: ${e.toString()}';
    }
  }

  // Delete employee
  Future<void> deleteEmployee(String employeeId) async {
    final employeesCollection = _employeesCollection;
    if (employeesCollection == null) throw 'User tidak terautentikasi';

    try {
      await employeesCollection.doc(employeeId).delete();
    } catch (e) {
      throw 'Gagal menghapus karyawan: ${e.toString()}';
    }
  }
}



