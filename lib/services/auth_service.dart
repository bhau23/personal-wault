import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'encryption_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;
  AuthService._();

  final _storage = const FlutterSecureStorage();
  static const _hashKey = 'master_password_hash';
  static const _saltKey = 'master_password_salt';

  Future<bool> isSetup() async {
    final hash = await _storage.read(key: _hashKey);
    return hash != null && hash.isNotEmpty;
  }

  Future<void> setup(String password) async {
    final salt = EncryptionService.generateSalt();
    final hash = EncryptionService.hashPassword(password, salt);
    await _storage.write(key: _saltKey, value: salt);
    await _storage.write(key: _hashKey, value: hash);
    EncryptionService().init(password);
  }

  Future<bool> verify(String password) async {
    final salt = await _storage.read(key: _saltKey);
    final storedHash = await _storage.read(key: _hashKey);
    if (salt == null || storedHash == null) return false;
    final hash = EncryptionService.hashPassword(password, salt);
    if (hash == storedHash) {
      EncryptionService().init(password);
      return true;
    }
    return false;
  }

  void lock() {
    EncryptionService().clear();
  }
}
