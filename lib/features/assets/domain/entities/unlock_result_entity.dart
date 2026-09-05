/// Cocok dengan `UnlockAssetResponse` backend (`GET /assets/:id/secret`).
///
/// PENTING: ini BUKAN kredensial plaintext. `systemShare` adalah salah satu
/// dari 2 bagian yang dibutuhkan Shamir combine — penggabungan dengan bagian
/// Eksekutor (tersimpan lokal) WAJIB dilakukan di klien lewat
/// `ShamirSecretSharing.combine()`, tidak pernah oleh server.
class UnlockResultEntity {
  final String assetId;
  final String assetName;
  final String platform;
  final String accountIdentifier;
  final String role; // 'EXECUTOR' | 'BENEFICIARY'
  final double percentageOwned;
  final String? systemShare;
  final String? notarisEncryptedShare;
  final String instruction;

  const UnlockResultEntity({
    required this.assetId,
    required this.assetName,
    required this.platform,
    required this.accountIdentifier,
    required this.role,
    required this.percentageOwned,
    required this.instruction,
    this.systemShare,
    this.notarisEncryptedShare,
  });

  bool get isExecutor => role == 'EXECUTOR';

  factory UnlockResultEntity.fromJson(Map<String, dynamic> json) {
    return UnlockResultEntity(
      assetId: json['assetId']?.toString() ?? '',
      assetName: json['assetName']?.toString() ?? '',
      platform: json['platform']?.toString() ?? '',
      accountIdentifier: json['accountIdentifier']?.toString() ?? '',
      role: json['role']?.toString() ?? 'BENEFICIARY',
      percentageOwned: (json['percentageOwned'] as num?)?.toDouble() ?? 0,
      systemShare: json['systemShare'] as String?,
      notarisEncryptedShare: json['notarisEncryptedShare'] as String?,
      instruction: json['instruction']?.toString() ?? '',
    );
  }
}
