/// Kredensial hasil rekonstruksi Shamir combine (Fase 0) — hasil `jsonDecode`
/// atas plaintext yang direkonstruksi, cocok dengan `VaultSecretPayload`
/// backend. Ini TIDAK PERNAH melewati jaringan dalam bentuk utuh — hanya ada
/// di memori perangkat Eksekutor setelah penggabungan lokal.
class VaultSecretEntity {
  final String? username;
  final String? password;
  final String? pin;
  final String? notes;

  /// Field di luar 4 field standar `VaultSecretDto` (mis. data lama dengan
  /// kunci berbeda). Tetap ditampilkan supaya kredensial yang berhasil
  /// direkonstruksi tidak "hilang" hanya karena namanya tidak dikenal.
  final Map<String, String> extras;

  const VaultSecretEntity({
    this.username,
    this.password,
    this.pin,
    this.notes,
    this.extras = const {},
  });

  static const _knownKeys = {'username', 'password', 'pin', 'notes'};

  bool get isEmpty =>
      username == null &&
      password == null &&
      pin == null &&
      notes == null &&
      extras.isEmpty;

  factory VaultSecretEntity.fromJson(Map<String, dynamic> json) {
    String? read(String key) {
      final value = json[key]?.toString();
      return (value == null || value.isEmpty) ? null : value;
    }

    return VaultSecretEntity(
      username: read('username'),
      password: read('password'),
      pin: read('pin'),
      notes: read('notes'),
      extras: {
        for (final entry in json.entries)
          if (!_knownKeys.contains(entry.key) &&
              (entry.value?.toString().isNotEmpty ?? false))
            entry.key: entry.value.toString(),
      },
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
