import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthSecureStorage {
  AuthSecureStorage._();

  static final AuthSecureStorage instance = AuthSecureStorage._();

  static const String _accessTokenKey = 'reso_access_token';

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<void> saveAccessToken(String token) {
    return _storage.write(key: _accessTokenKey, value: token);
  }

  Future<String?> readAccessToken() {
    return _storage.read(key: _accessTokenKey);
  }

  Future<void> clearAccessToken() {
    return _storage.delete(key: _accessTokenKey);
  }
}
