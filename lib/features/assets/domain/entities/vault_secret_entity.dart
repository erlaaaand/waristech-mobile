/// Kredensial hasil rekonstruksi Shamir combine (Fase 0) — hasil `jsonDecode`
/// atas plaintext yang direkonstruksi, cocok dengan `VaultSecretPayload`
/// backend. Ini TIDAK PERNAH melewati jaringan dalam bentuk utuh — hanya ada
/// di memori perangkat Eksekutor setelah penggabungan lokal.
class VaultSecretEntity {
  final String? username;
  final String? password;
  final String? pin;
  final String? notes;

  const VaultSecretEntity({this.username, this.password, this.pin, this.notes});

  factory VaultSecretEntity.fromJson(Map<String, dynamic> json) {
    return VaultSecretEntity(
      username: json['username'] as String?,
      password: json['password'] as String?,
      pin: json['pin'] as String?,
      notes: json['notes'] as String?,
    );
  }
}

/// Dilempar saat bagian kunci Eksekutor tidak ditemukan di perangkat ini
/// (aplikasi diinstal ulang, pindah perangkat tanpa cadangan, dsb).
class MissingExecutorShareException implements Exception {
  final String message;
  const MissingExecutorShareException([
    this.message = 'Bagian kunci Eksekutor tidak ditemukan di perangkat ini. Aset tidak dapat dibuka dari sini — hubungi Notaris atau ajukan fallback hukum.',
  ]);
  @override
  String toString() => message;
}
