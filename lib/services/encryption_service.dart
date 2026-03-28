import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:crypto/crypto.dart';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._();
  factory EncryptionService() => _instance;
  EncryptionService._();

  enc.Key? _key;
  bool get isInitialized => _key != null;

  /// Derives a 256-bit AES key from the master password using SHA-256.
  void init(String masterPassword) {
    final hash = sha256.convert(utf8.encode(masterPassword));
    _key = enc.Key(Uint8List.fromList(hash.bytes));
  }

  void clear() {
    _key = null;
  }

  /// Encrypts plaintext using AES-256-CBC with a random 16-byte IV.
  /// Returns: base64(iv) + ':' + base64(ciphertext)
  String encrypt(String plaintext) {
    if (_key == null) throw StateError('EncryptionService not initialized');
    if (plaintext.isEmpty) return '';
    final iv = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(_key!, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  /// Decrypts ciphertext produced by [encrypt].
  /// Returns null on failure instead of silently masking errors.
  String? decrypt(String ciphertext) {
    if (_key == null) throw StateError('EncryptionService not initialized');
    if (ciphertext.isEmpty) return '';
    try {
      final sep = ciphertext.indexOf(':');
      if (sep == -1) return null;
      final iv = enc.IV.fromBase64(ciphertext.substring(0, sep));
      final data = ciphertext.substring(sep + 1);
      final encrypter = enc.Encrypter(enc.AES(_key!, mode: enc.AESMode.cbc));
      return encrypter.decrypt64(data, iv: iv);
    } catch (_) {
      return null;
    }
  }

  /// Hashes a password with a salt for storage verification.
  static String hashPassword(String password, String salt) {
    return sha256.convert(utf8.encode(password + salt)).toString();
  }

  /// Generates a cryptographically secure random salt.
  static String generateSalt() {
    final random = Random.secure();
    final bytes = List.generate(32, (_) => random.nextInt(256));
    return base64Encode(Uint8List.fromList(bytes));
  }

  /// Generates a random password of given length.
  static String generatePassword({int length = 20}) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()_+-=';
    final random = Random.secure();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)])
        .join();
  }
}
