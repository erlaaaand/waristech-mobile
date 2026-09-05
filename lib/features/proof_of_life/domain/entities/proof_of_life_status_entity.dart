/// Tahap Proof-of-Life — cocok persis dengan `ProofOfLifeStage` enum backend.
enum ProofOfLifeStage {
  active,
  warning,
  emergencyContact,
  formalVerification;

  static ProofOfLifeStage fromString(String value) {
    switch (value.toUpperCase()) {
      case 'WARNING':
        return ProofOfLifeStage.warning;
      case 'EMERGENCY_CONTACT':
        return ProofOfLifeStage.emergencyContact;
      case 'FORMAL_VERIFICATION':
        return ProofOfLifeStage.formalVerification;
      default:
        return ProofOfLifeStage.active;
    }
  }

  String get displayLabel {
    switch (this) {
      case ProofOfLifeStage.active:
        return 'Aktif & Aman';
      case ProofOfLifeStage.warning:
        return 'Tahap Peringatan';
      case ProofOfLifeStage.emergencyContact:
        return 'Kontak Darurat Dihubungi';
      case ProofOfLifeStage.formalVerification:
        return 'Verifikasi Resmi Berjalan';
    }
  }
}

/// Status Proof-of-Life Pewaris saat ini — GET /proof-of-life/status.
class ProofOfLifeStatusEntity {
  final DateTime lastCheckInAt;
  final ProofOfLifeStage stage;
  final DateTime nextCheckInDueAt;
  final int daysUntilDue;

  const ProofOfLifeStatusEntity({
    required this.lastCheckInAt,
    required this.stage,
    required this.nextCheckInDueAt,
    required this.daysUntilDue,
  });

  factory ProofOfLifeStatusEntity.fromJson(Map<String, dynamic> json) {
    return ProofOfLifeStatusEntity(
      lastCheckInAt:
          DateTime.tryParse(json['lastCheckInAt'] as String? ?? '') ??
          DateTime.now(),
      stage: ProofOfLifeStage.fromString(json['stage'] as String? ?? ''),
      nextCheckInDueAt:
          DateTime.tryParse(json['nextCheckInDueAt'] as String? ?? '') ??
          DateTime.now(),
      daysUntilDue: (json['daysUntilDue'] as num? ?? 0).toInt(),
    );
  }
}
