import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:basic_utils/basic_utils.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/export.dart';

/// Keypair RSA-2048 milik Notaris untuk penitipan bagian kunci NOTARIS.
///
/// Private key TIDAK PERNAH dikirim ke server — hanya disimpan di
/// `flutter_secure_storage` perangkat Notaris. Server hanya menerima
/// public key (PEM/SPKI) via POST /users/me/public-key, lalu Pewaris
/// memakainya untuk mengenkripsi (RSA-OAEP) bagian kunci NOTARIS sebelum
/// dititipkan — server menyimpan ciphertext yang tidak dapat ia buka.
class RsaKeypairService {
  static const _storage = FlutterSecureStorage();
  static const _privateKeyStorageKey = 'notaris_rsa_private_key_pem';
  static const _publicKeyStorageKey = 'notaris_rsa_public_key_pem';

  /// Buat keypair RSA-2048 baru (PEM). Menimpa keypair lama bila ada —
  /// panggil hanya saat pendaftaran awal.
  static Future<({String publicKeyPem, String privateKeyPem})>
  generateKeypair() async {
    final secureRandom = _seededSecureRandom();
    final keyGen = RSAKeyGenerator()
      ..init(
        ParametersWithRandom(
          RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64),
          secureRandom,
        ),
      );
    final pair = keyGen.generateKeyPair();
    final publicKey = pair.publicKey;
    final privateKey = pair.privateKey;

    final publicKeyPem = CryptoUtils.encodeRSAPublicKeyToPem(publicKey);
    final privateKeyPem = CryptoUtils.encodeRSAPrivateKeyToPem(privateKey);

    await _storage.write(key: _privateKeyStorageKey, value: privateKeyPem);
    await _storage.write(key: _publicKeyStorageKey, value: publicKeyPem);

    return (publicKeyPem: publicKeyPem, privateKeyPem: privateKeyPem);
  }

  static Future<String?> readStoredPublicKeyPem() {
    return _storage.read(key: _publicKeyStorageKey);
  }

  static Future<String?> readStoredPrivateKeyPem() {
    return _storage.read(key: _privateKeyStorageKey);
  }

  static Future<bool> hasKeypair() async {
    final key = await readStoredPrivateKeyPem();
    return key != null && key.isNotEmpty;
  }

  /// Enkripsi [plaintext] dengan public key PEM (SPKI) Notaris tujuan —
  /// dipakai Pewaris sebelum menitipkan bagian kunci NOTARIS ke server.
  /// Hasil di-encode base64 sesuai kontrak `EscrowNotarisShareDto.encryptedShare`.
  static String encryptWithPublicKeyPem(String plaintext, String publicKeyPem) {
    final publicKey = CryptoUtils.rsaPublicKeyFromPem(publicKeyPem);
    final encryptor = OAEPEncoding(RSAEngine())
      ..init(true, PublicKeyParameter<RSAPublicKey>(publicKey));
    final input = Uint8List.fromList(utf8.encode(plaintext));
    final output = _processInBlocks(encryptor, input);
    return base64.encode(output);
  }

  /// Dekripsi ciphertext base64 dengan private key Notaris yang tersimpan
  /// lokal — dipakai saat jalur fallback hukum (Notaris membuka titipannya).
  static Future<String> decryptWithStoredPrivateKey(
    String ciphertextBase64,
  ) async {
    final privateKeyPem = await readStoredPrivateKeyPem();
    if (privateKeyPem == null) {
      throw StateError('Belum ada keypair RSA tersimpan di perangkat ini.');
    }
    final privateKey = CryptoUtils.rsaPrivateKeyFromPem(privateKeyPem);
    final decryptor = OAEPEncoding(RSAEngine())
      ..init(false, PrivateKeyParameter<RSAPrivateKey>(privateKey));
    final input = base64.decode(ciphertextBase64);
    final output = _processInBlocks(decryptor, input);
    return utf8.decode(output);
  }

  static Uint8List _processInBlocks(
    AsymmetricBlockCipher engine,
    Uint8List input,
  ) {
    final numBlocks = (input.length / engine.inputBlockSize).ceil().clamp(
      1,
      1 << 30,
    );
    final output = BytesBuilder();
    for (var i = 0; i < numBlocks; i++) {
      final start = i * engine.inputBlockSize;
      final end = min(start + engine.inputBlockSize, input.length);
      if (start >= end) break;
      output.add(engine.process(input.sublist(start, end)));
    }
    return output.toBytes();
  }

  static SecureRandom _seededSecureRandom() {
    final secureRandom = FortunaRandom();
    final seedSource = Random.secure();
    final seeds = List<int>.generate(32, (_) => seedSource.nextInt(256));
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
    return secureRandom;
  }
}
