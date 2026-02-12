import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static final LocalAuthentication _localAuthentication = LocalAuthentication();

  static const _masterPasswordKey = 'master_password_hash';
  static const _bioEnabledKey = 'biometric_enabled';
  static const _isRegisteredKey = 'is_registered';

  static Future<bool> isUserRegistered() async {
    final registered = await _storage.read(key: _isRegisteredKey);
    return registered == 'true';
  }

  static Future<void> registerMasterPassword(String password) async {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    await _storage.write(key: _masterPasswordKey, value: hash.toString());
  }

  static Future<bool> verifyMasterPassword(String password) async {
    final storedHash = await _storage.read(key: _masterPasswordKey);

    if (storedHash == null) return false;

    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString() == storedHash;
  }

  static Future<bool> canUseBio() async {
    try {
      return await _localAuthentication.canCheckBiometrics;
    } catch(e) {
      return false;
    }
  }

  static Future<void> enableBiometric() async {
    await _storage.write(key: _bioEnabledKey, value: 'true');
  }

  static Future<void> disableBiometric() async {
    await _storage.write(key: _bioEnabledKey, value: 'false');
  }


}