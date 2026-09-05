/// Satu baris rincian pembagian untuk seorang ahli waris — hasil
/// `POST /calculation/simulate` (`ShareDetailDomain` di backend).
class ShareDetailEntity {
  final String ahliWarisId;
  final String relationshipDescription;
  final String ratio;
  final double calculatedPercentage;

  const ShareDetailEntity({
    required this.ahliWarisId,
    required this.relationshipDescription,
    required this.ratio,
    required this.calculatedPercentage,
  });

  factory ShareDetailEntity.fromJson(Map<String, dynamic> json) {
    return ShareDetailEntity(
      ahliWarisId: json['ahliWarisId']?.toString() ?? '',
      relationshipDescription:
          json['relationshipDescription']?.toString() ?? '',
      ratio: json['ratio']?.toString() ?? '',
      calculatedPercentage:
          (json['calculatedPercentage'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Hasil simulasi pembagian waris — `POST /calculation/simulate`.
/// Murni simulasi (belum disimpan ke database di sisi backend).
class CalculationResultEntity {
  final String pewarisId;
  final String method;
  final double baseUnit;
  final List<ShareDetailEntity> shares;

  const CalculationResultEntity({
    required this.pewarisId,
    required this.method,
    required this.baseUnit,
    required this.shares,
  });

  factory CalculationResultEntity.fromJson(Map<String, dynamic> json) {
    final rawShares = json['shares'];
    return CalculationResultEntity(
      pewarisId: json['pewarisId']?.toString() ?? '',
      method: json['method']?.toString() ?? '',
      baseUnit: (json['baseUnit'] as num?)?.toDouble() ?? 100,
      shares: rawShares is List
          ? rawShares
                .whereType<Map<String, dynamic>>()
                .map(ShareDetailEntity.fromJson)
                .toList()
          : const [],
    );
  }

  /// Total seluruh persentase — dipakai UI untuk menampilkan cek "jumlah 100%".
  double get totalPercentage =>
      shares.fold(0, (sum, s) => sum + s.calculatedPercentage);
}
