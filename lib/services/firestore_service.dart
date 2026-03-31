import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/credential.dart';
import 'encryption_service.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._();
  factory FirestoreService() => _instance;
  FirestoreService._();

  final _firestore = FirebaseFirestore.instance;
  final _crypto = EncryptionService();
  String? _userId;

  void setUser(String userId) => _userId = userId;

  CollectionReference get _items {
    if (_userId == null) throw StateError('User not set');
    return _firestore.collection('vaults').doc(_userId).collection('items');
  }

  /// Real-time stream of all credentials, decrypted.
  /// Updates automatically when data changes on any device.
  Stream<List<Credential>> watchCredentials() {
    return _items
        .orderBy('lastUpdated', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          final payload = doc['encryptedPayload'] as String;
          final decrypted = _crypto.decrypt(payload);
          if (decrypted == null) return null;
          final map = jsonDecode(decrypted) as Map<String, dynamic>;
          return Credential.fromMap(map, id: doc.id);
        } catch (_) {
          return null;
        }
      }).whereType<Credential>().toList();
    });
  }

  /// Saves (create or update) a credential to Firestore.
  /// Data is encrypted before leaving the device.
  Future<void> saveCredential(Credential cred) async {
    final jsonStr = jsonEncode(cred.toMap());
    final encrypted = _crypto.encrypt(jsonStr);
    final data = {
      'encryptedPayload': encrypted,
      'lastUpdated': FieldValue.serverTimestamp(),
    };

    if (cred.id != null) {
      await _items.doc(cred.id).update(data);
    } else {
      await _items.add(data);
    }
  }

  /// Deletes a credential from Firestore.
  Future<void> deleteCredential(String docId) async {
    await _items.doc(docId).delete();
  }

  /// Toggles the favorite status of a credential.
  Future<void> toggleFavorite(Credential cred) async {
    final updated = cred.copyWith(isFavorite: !cred.isFavorite);
    await saveCredential(updated);
  }
}
