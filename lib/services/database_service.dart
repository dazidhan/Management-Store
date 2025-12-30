import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  DocumentReference? get _userDoc {
    final uid = currentUserId;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid);
  }

  DocumentReference? get _storeProfileDoc =>
      _userDoc?.collection('store_profile').doc('profile');
  Stream<DocumentSnapshot>? getStoreProfile() => _storeProfileDoc?.snapshots();
  Future<void> setStoreProfile({
    required String storeName,
    required String address,
  }) async {
    if (_storeProfileDoc == null) throw 'User tidak terautentikasi';
    await _storeProfileDoc!.set({
      'storeName': storeName,
      'address': address,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  CollectionReference? get _stockHistoryCollection =>
      _userDoc?.collection('stock_history');

  Stream<QuerySnapshot>? getStockHistory() {
    return _stockHistoryCollection
        ?.orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> _logStock({
    required String productId,
    required String name,
    required int qty,
    required String type,
    required String reason,
    WriteBatch? batch,
  }) async {
    final historyCollection = _stockHistoryCollection;
    if (historyCollection == null) return;

    final data = {
      'productId': productId,
      'name': name,
      'qty': qty,
      'type': type,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
    };

    if (batch != null) {
      batch.set(historyCollection.doc(), data);
    } else {
      await historyCollection.add(data);
    }
  }

  CollectionReference? get _productsCollection =>
      _userDoc?.collection('products');

  Stream<QuerySnapshot>? getProducts() =>
      _productsCollection?.orderBy('name').snapshots();

  Future<DocumentSnapshot?> getProductByBarcode(String barcode) async {
    final query = await _productsCollection
        ?.where('barcode', isEqualTo: barcode)
        .limit(1)
        .get();
    return (query != null && query.docs.isNotEmpty) ? query.docs.first : null;
  }

  Future<String> addProduct(Map<String, dynamic> productData) async {
    if (_productsCollection == null) throw 'User tidak terautentikasi';

    final docRef = await _productsCollection!.add({
      ...productData,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final initialStock = (productData['stock'] as num?)?.toInt() ?? 0;

    if (initialStock > 0) {
      await _logStock(
        productId: docRef.id,
        name: productData['name'] ?? 'Produk Baru',
        qty: initialStock,
        type: 'in',
        reason: 'Barang Baru',
      );
    }
    return docRef.id;
  }

  Future<void> updateProduct(
    String productId,
    Map<String, dynamic> newData,
  ) async {
    if (_productsCollection == null) throw 'User tidak terautentikasi';

    final oldDoc = await _productsCollection!.doc(productId).get();
    final oldData = oldDoc.data() as Map<String, dynamic>;

    final oldStock = (oldData['stock'] as num?)?.toInt() ?? 0;
    final newStock = (newData['stock'] as num?)?.toInt() ?? 0;

    await _productsCollection!.doc(productId).update({
      ...newData,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final diff = newStock - oldStock;
    if (diff != 0) {
      await _logStock(
        productId: productId,
        name: newData['name'] ?? oldData['name'] ?? 'Produk',
        qty: diff.abs(),
        type: diff > 0 ? 'in' : 'out',
        reason: diff > 0 ? 'Restock / Tambah' : 'Koreksi Stok',
      );
    }
  }

  Future<void> deleteProduct(String productId) async =>
      await _productsCollection!.doc(productId).delete();

  CollectionReference? get _transactionsCollection =>
      _userDoc?.collection('transactions');

  Stream<QuerySnapshot>? getTransactions() => _transactionsCollection
      ?.orderBy('createdAt', descending: true)
      .snapshots();

  Future<void> processCheckout({
    required Map<String, Map<String, dynamic>> cartItems,
    required String customerName,
    required double totalPrice,
    required int totalItems,
  }) async {
    if (_transactionsCollection == null) throw 'User tidak terautentikasi';

    final batch = _firestore.batch();
    final transactionRef = _transactionsCollection!.doc();
    final itemList = <Map<String, dynamic>>[];

    for (var entry in cartItems.entries) {
      final productId = entry.key;
      final itemData = entry.value;
      final qtyBuy = (itemData['qty'] as num).toInt();

      itemList.add({
        'productId': productId,
        'name': itemData['name'],
        'price': itemData['price'],
        'qty': qtyBuy,
      });

      final productRef = _productsCollection!.doc(productId);
      batch.update(productRef, {
        'stock': FieldValue.increment(-qtyBuy),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final historyRef = _stockHistoryCollection!.doc();
      batch.set(historyRef, {
        'productId': productId,
        'name': itemData['name'],
        'qty': qtyBuy,
        'type': 'out',
        'reason': 'Penjualan',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    batch.set(transactionRef, {
      'customerName': customerName,
      'totalPrice': totalPrice,
      'totalItems': totalItems,
      'items': itemList,
      'status': 'completed',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  CollectionReference? get _employeesCollection =>
      _userDoc?.collection('employees');
  Stream<QuerySnapshot>? getEmployees() =>
      _employeesCollection?.orderBy('name').snapshots();
  Future<String> addEmployee(Map<String, dynamic> data) async {
    final ref = await _employeesCollection!.add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> updateEmployee(String id, Map<String, dynamic> data) async =>
      await _employeesCollection!.doc(id).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
  Future<void> deleteEmployee(String id) async =>
      await _employeesCollection!.doc(id).delete();
}
