import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/wallet/domain/entities/wallet_entity.dart';
import '../../features/transaction/domain/entities/transaction_entity.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Wallet Sync ---
  Future<String?> syncWallet(WalletEntity wallet) async {
    try {
      final docRef = wallet.firestoreId != null
          ? _firestore
                .collection('users')
                .doc(wallet.userId)
                .collection('wallets')
                .doc(wallet.firestoreId)
          : _firestore
                .collection('users')
                .doc(wallet.userId)
                .collection('wallets')
                .doc();

      await docRef.set(wallet.toJson());
      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  // --- Transaction Sync ---
  Future<String?> syncTransaction(TransactionEntity transaction) async {
    try {
      final docRef = transaction.firestoreId != null
          ? _firestore
                .collection('users')
                .doc(transaction.userId)
                .collection('transactions')
                .doc(transaction.firestoreId)
          : _firestore
                .collection('users')
                .doc(transaction.userId)
                .collection('transactions')
                .doc();

      await docRef.set(transaction.toJson());
      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  // --- Pull Data ---
  Future<List<WalletEntity>> getWallets(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('wallets')
        .get();
    return snapshot.docs
        .map((doc) => WalletEntity.fromJson(doc.data(), doc.id))
        .toList();
  }

  Future<List<TransactionEntity>> getTransactions(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .get();
    return snapshot.docs
        .map((doc) => TransactionEntity.fromJson(doc.data(), doc.id))
        .toList();
  }
}
