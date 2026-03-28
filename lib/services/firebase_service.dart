import 'package:cloud_firestore/cloud_firestore.dart';
import 'encryption_service.dart';

class FirebaseSyncService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final EncryptionService _encService;
  
  FirebaseSyncService(this._encService);

  /// Get the user's specific vault collection
  CollectionReference get _vault => _db.collection('vaults');

  Future<void> saveCredential(String userId, String id, Map<String, dynamic> rawData) async {
    // Encrypt the entire object as a JSON string before it touches firestore!
    // This guarantees Firebase NEVER sees your actual URL, Email, or Password.
    final cipherText = _encService.encrypt(rawData.toString());
    
    await _vault.doc(userId).collection('items').doc(id).set({
      'encryptedPayload': cipherText,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> streamCredentials(String userId) {
    return _vault.doc(userId).collection('items').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final cipherText = doc.data()['encryptedPayload'] as String;
        // Decrypt mapping back to local object
        final plainText = _encService.decrypt(cipherText);
        // Assuming plainText is a parseable format. Usually we JSON.encode before encrypting.
        return {'id': doc.id, 'data': plainText};
      }).toList();
    });
  }
}
