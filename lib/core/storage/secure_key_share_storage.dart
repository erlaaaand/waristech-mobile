import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Penyimpanan bagian kunci Eksekutor per aset di penyimpanan aman perangkat.
///
/// Ini SATU-SATUNYA salinan bagian kunci Eksekutor yang ada di luar server —
/// server hanya menyimpan bagian SYSTEM. Kalau ini hilang (aplikasi dihapus,
/// pindah perangkat tanpa cadangan), aset TIDAK BISA dibuka lagi kecuali
/// lewat jalur Notaris (bagian NOTARIS) atau fallback hukum konvensional.
class SecureKeyShareStorage {
  static const _storage = FlutterSecureStorage();

  static String _executorKey(String assetId) => 'executor_share_$assetId';

  static Future<void> saveExecutorShare(String assetId, String share) {
    return _storage.write(key: _executorKey(assetId), value: share);
  }

  static Future<String?> readExecutorShare(String assetId) {
    return _storage.read(key: _executorKey(assetId));
  }

  static Future<void> deleteExecutorShare(String assetId) {
    return _storage.delete(key: _executorKey(assetId));
  }

  static Future<bool> hasExecutorShare(String assetId) async {
    final value = await readExecutorShare(assetId);
    return value != null && value.isNotEmpty;
  }
}
