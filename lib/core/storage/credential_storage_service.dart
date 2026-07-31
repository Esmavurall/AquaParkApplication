import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CredentialStorageService {
  static const String _tenantKey = 'login_tenant';
  static const String _usernameKey = 'login_username';
  static const String _passwordKey = 'login_password';

  final FlutterSecureStorage _storage =
  const FlutterSecureStorage();

  Future<void> saveCredentials({
    required String tenant,
    required String username,
    required String password,
  }) async {
    await _storage.write(
      key: _tenantKey,
      value: tenant,
    );

    await _storage.write(
      key: _usernameKey,
      value: username,
    );

    await _storage.write(
      key: _passwordKey,
      value: password,
    );
  }

  Future<String?> readTenant() async {
    return await _storage.read(key: _tenantKey);
  }

  Future<String?> readUsername() async {
    return await _storage.read(key: _usernameKey);
  }

  Future<String?> readPassword() async {
    return await _storage.read(key: _passwordKey);
  }

  Future<void> deletePassword() async {
    await _storage.delete(key: _passwordKey);
  }

  Future<void> deleteAllCredentials() async {
    await _storage.delete(key: _tenantKey);
    await _storage.delete(key: _usernameKey);
    await _storage.delete(key: _passwordKey);
  }
}