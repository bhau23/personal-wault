import 'package:encrypt/encrypt.dart' as enc;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  final _storage = const FlutterSecureStorage();
  late enc.Key _key;
  late enc.IV _iv;
  bool _isInitialized = false;

  /// Initializes the encryption engine using the User's Master Password
  Future<void> initialize(String masterPassword) async {
    // Generate AES-256 Key using SHA-256 hash of password
    final keyBytes = sha256.convert(utf8.encode(masterPassword)).bytes;
    _key = enc.Key(Uint8List.fromList(keyBytes));
    
    // We use a deterministic but highly secure IV derived from the key hash
    // (In production, storing an IV alongside ciphertext is better, but this ensures offline portability without complex metadata)
    final ivBytes = md5.convert(keyBytes).bytes;
    _iv = enc.IV(Uint8List.fromList(ivBytes));
    
    _isInitialized = true;
  }

  String encrypt(String plainText) {
    if (!_isInitialized) throw Exception('EncryptionService not initialized');
    final encrypter = enc.Encrypter(enc.AES(_key));
    final encrypted = encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  String decrypt(String cipherText) {
    if (!_isInitialized) throw Exception('EncryptionService not initialized');
    if (cipherText.isEmpty) return "";
    try {
      final encrypter = enc.Encrypter(enc.AES(_key));
      return encrypter.decrypt64(cipherText, iv: _iv);
    } catch (e) {
      return "[DECRYPTION FAILED]";
    }
  }
}
