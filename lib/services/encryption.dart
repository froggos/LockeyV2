import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  static const _storage = FlutterSecureStorage();
  static const _keyStorageKey = 'master_encryption_key';
  static final _algo = AesGcm.with256bits();

  static Future<void> generateMasterKey() async {
    final secretKey = await _algo.newSecretKey();
    final keyBytes = await secretKey.extractBytes();
    final keyBase64 = base64Encode(keyBytes);
    await _storage.write(key: _keyStorageKey, value: keyBase64,);
  }

  static Future<SecretKey> _getMasterKey() async {
    final keyBase64 = await _storage.read(key: _keyStorageKey);

    if (keyBase64 == null) {
      await generateMasterKey();
      return _getMasterKey();
    }

    final keyBytes = base64Decode(keyBase64);
    return SecretKey(keyBytes);
  }

  static Future<bool> hasMasterKey() async {
    final key = await _storage.read(key: _keyStorageKey);
    return key != null;
  }

  static Future<String> encrypt(String plainText) async {
    if (plainText.isEmpty) return '';

    final secretKey = await _getMasterKey();

    final plainBytes = utf8.encode(plainText);

    final secretBox = await _algo.encrypt(plainBytes, secretKey: secretKey);

    final combined = <int>[
      ...secretBox.nonce,
      ...secretBox.cipherText,
      ...secretBox.mac.bytes,
    ];

    return base64Encode(combined);
  }

  static Future<String> decrypt(String encrypted) async {
    if (encrypted.isEmpty) return '';

    try {
      final secretKey = await _getMasterKey();

      final combined = base64Decode(encrypted);

      final nonce = combined.sublist(0, 12);
      final mac = combined.sublist(combined.length - 16);
      final cipherText = combined.sublist(12, combined.length - 16);

      final secretBox = SecretBox(cipherText, nonce: nonce, mac: Mac(mac),);

      final decrypted = await _algo.decrypt(secretBox, secretKey: secretKey);

      return utf8.decode(decrypted);
    } catch(e) {
      throw Exception('Error al desencriptar: $e');
    }
  }

  static Future<void> deleteMasterKey() async {
    await _storage.delete(key: _keyStorageKey);
  }
}