/// Jenis aset — cocok persis dengan AssetType enum backend.
enum AssetType {
  crypto,
  saham,
  reksaDana,
  obligasi,
  eWallet,
  rekeningBank,
  asuransiJiwa,
  p2pLending,
  emasDigital,
  nft,
  domainWebsite,
  lainnya;

  static AssetType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'CRYPTO':
        return AssetType.crypto;
      case 'SAHAM':
        return AssetType.saham;
      case 'REKSA_DANA':
        return AssetType.reksaDana;
      case 'OBLIGASI':
        return AssetType.obligasi;
      case 'E_WALLET':
        return AssetType.eWallet;
      case 'REKENING_BANK':
        return AssetType.rekeningBank;
      case 'ASURANSI_JIWA':
        return AssetType.asuransiJiwa;
      case 'P2P_LENDING':
        return AssetType.p2pLending;
      case 'EMAS_DIGITAL':
        return AssetType.emasDigital;
      case 'NFT':
        return AssetType.nft;
      case 'DOMAIN_WEBSITE':
        return AssetType.domainWebsite;
      default:
        return AssetType.lainnya;
    }
  }

  String get displayName {
    switch (this) {
      case AssetType.crypto:
        return 'Crypto';
      case AssetType.saham:
        return 'Saham';
      case AssetType.reksaDana:
        return 'Reksa Dana';
      case AssetType.obligasi:
        return 'Obligasi / SBN';
      case AssetType.eWallet:
        return 'E-Wallet';
      case AssetType.rekeningBank:
        return 'Rekening Bank';
      case AssetType.asuransiJiwa:
        return 'Asuransi Jiwa';
      case AssetType.p2pLending:
        return 'P2P Lending';
      case AssetType.emasDigital:
        return 'Emas Digital';
      case AssetType.nft:
        return 'NFT';
      case AssetType.domainWebsite:
        return 'Domain/Website';
      case AssetType.lainnya:
        return 'Lainnya';
    }
  }

  /// Nilai string untuk dikirim ke backend (POST /assets).
  String get backendValue {
    switch (this) {
      case AssetType.crypto:
        return 'CRYPTO';
      case AssetType.saham:
        return 'SAHAM';
      case AssetType.reksaDana:
        return 'REKSA_DANA';
      case AssetType.obligasi:
        return 'OBLIGASI';
      case AssetType.eWallet:
        return 'E_WALLET';
      case AssetType.rekeningBank:
        return 'REKENING_BANK';
      case AssetType.asuransiJiwa:
        return 'ASURANSI_JIWA';
      case AssetType.p2pLending:
        return 'P2P_LENDING';
      case AssetType.emasDigital:
        return 'EMAS_DIGITAL';
      case AssetType.nft:
        return 'NFT';
      case AssetType.domainWebsite:
        return 'DOMAIN_WEBSITE';
      case AssetType.lainnya:
        return 'LAINNYA';
    }
  }
}

/// Status aset — cocok persis dengan AssetStatus enum backend.
enum AssetStatus {
  pendingVerification,
  verified,
  rejected,
  frozen,
  pendingCooldown,
  unlocked,
  liquidating,
  distributed,
  disputedLiquidation,
  closed;

  static AssetStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'VERIFIED':
        return AssetStatus.verified;
      case 'REJECTED':
        return AssetStatus.rejected;
      case 'FROZEN':
        return AssetStatus.frozen;
      case 'PENDING_COOLDOWN':
        return AssetStatus.pendingCooldown;
      case 'UNLOCKED':
        return AssetStatus.unlocked;
      case 'LIQUIDATING':
        return AssetStatus.liquidating;
      case 'DISTRIBUTED':
        return AssetStatus.distributed;
      case 'DISPUTED_LIQUIDATION':
        return AssetStatus.disputedLiquidation;
      case 'CLOSED':
        return AssetStatus.closed;
      default:
        return AssetStatus.pendingVerification;
    }
  }

  String get displayLabel {
    switch (this) {
      case AssetStatus.pendingVerification:
        return 'Menunggu Verifikasi';
      case AssetStatus.verified:
        return 'Terverifikasi';
      case AssetStatus.rejected:
        return 'Ditolak';
      case AssetStatus.frozen:
        return 'Dibekukan';
      case AssetStatus.pendingCooldown:
        return 'Masa Tunda 14 Hari';
      case AssetStatus.unlocked:
        return 'Brankas Terbuka';
      case AssetStatus.liquidating:
        return 'Sedang Dicairkan';
      case AssetStatus.distributed:
        return 'Didistribusikan';
      case AssetStatus.disputedLiquidation:
        return 'Sengketa';
      case AssetStatus.closed:
        return 'Ditutup';
    }
  }
}

/// Cara sistem memperlakukan kredensial aset — cocok persis dengan
/// AssetCustodyType enum backend.
enum AssetCustodyType {
  /// Kredensial dititipkan & dipecah Shamir (2-dari-3). Buka lewat GET /assets/:id/secret.
  vault,

  /// Kredensial TIDAK dititipkan — sistem hanya menyediakan panduan.
  /// Buka lewat GET /assets/:id/guidance.
  guidance;

  static AssetCustodyType fromString(String value) {
    return value.toUpperCase() == 'GUIDANCE'
        ? AssetCustodyType.guidance
        : AssetCustodyType.vault;
  }
}

class AssetEntity {
  final String id;
  final String pewarisId;
  final AssetType type;
  final String assetName;
  final String platform;
  final String accountIdentifier;
  final AssetCustodyType custodyType;
  final AssetStatus status;
  final String? verifiedByNotarisId;
  final DateTime? verifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<AssetAllocationEntity> allocations;

  const AssetEntity({
    required this.id,
    required this.pewarisId,
    required this.type,
    required this.assetName,
    required this.platform,
    required this.accountIdentifier,
    required this.custodyType,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.verifiedByNotarisId,
    this.verifiedAt,
    this.allocations = const [],
  });

  /// Aset yang kredensialnya dititipkan (punya bagian kunci untuk dibuka).
  bool get isVaultCustody => custodyType == AssetCustodyType.vault;

  factory AssetEntity.fromJson(Map<String, dynamic> json) {
    return AssetEntity(
      id: json['id'] as String? ?? '',
      pewarisId: json['pewarisId'] as String? ?? '',
      type: AssetType.fromString(json['type'] as String? ?? ''),
      assetName: json['assetName'] as String? ?? '',
      platform: json['platform'] as String? ?? '',
      accountIdentifier: json['accountIdentifier'] as String? ?? '',
      custodyType: AssetCustodyType.fromString(
        json['custodyType'] as String? ?? 'VAULT',
      ),
      status: AssetStatus.fromString(json['status'] as String? ?? ''),
      verifiedByNotarisId: json['verifiedByNotarisId'] as String?,
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.tryParse(json['verifiedAt'] as String)
          : null,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      allocations: (json['allocations'] as List<dynamic>? ?? [])
          .map((e) => AssetAllocationEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Status peninjauan bukti pencairan — cocok persis dengan
/// LiquidationProofStatus enum backend.
enum LiquidationProofStatus {
  pendingReview,
  approved,
  rejected;

  static LiquidationProofStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'APPROVED':
        return LiquidationProofStatus.approved;
      case 'REJECTED':
        return LiquidationProofStatus.rejected;
      default:
        return LiquidationProofStatus.pendingReview;
    }
  }

  String get displayLabel {
    switch (this) {
      case LiquidationProofStatus.pendingReview:
        return 'Menunggu Tinjauan';
      case LiquidationProofStatus.approved:
        return 'Disetujui';
      case LiquidationProofStatus.rejected:
        return 'Ditolak';
    }
  }
}

/// Bukti pencairan (e-Statement) yang diunggah Eksekutor — ditinjau Notaris.
class LiquidationProofEntity {
  final String id;
  final String assetId;
  final String assetName;
  final String executorId;
  final String pdfFileUrl;
  final String? pdfPassword;
  final LiquidationProofStatus status;
  final String? validationNotes;
  final DateTime createdAt;

  const LiquidationProofEntity({
    required this.id,
    required this.assetId,
    required this.assetName,
    required this.executorId,
    required this.pdfFileUrl,
    required this.status,
    required this.createdAt,
    this.pdfPassword,
    this.validationNotes,
  });

  factory LiquidationProofEntity.fromJson(Map<String, dynamic> json) {
    return LiquidationProofEntity(
      id: json['id'] as String? ?? '',
      assetId: json['assetId'] as String? ?? '',
      assetName: json['assetName'] as String? ?? '',
      executorId: json['executorId'] as String? ?? '',
      pdfFileUrl: json['pdfFileUrl'] as String? ?? '',
      pdfPassword: json['pdfPassword'] as String?,
      status: LiquidationProofStatus.fromString(
        json['status'] as String? ?? '',
      ),
      validationNotes: json['validationNotes'] as String?,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class AssetAllocationEntity {
  final String id;
  final String assetId;
  final String ahliWarisId;
  final double percentage;
  final bool isExecutor;
  final DateTime? acknowledgedAt;
  final DateTime createdAt;

  const AssetAllocationEntity({
    required this.id,
    required this.assetId,
    required this.ahliWarisId,
    required this.percentage,
    required this.isExecutor,
    required this.createdAt,
    this.acknowledgedAt,
  });

  factory AssetAllocationEntity.fromJson(Map<String, dynamic> json) {
    return AssetAllocationEntity(
      id: json['id'] as String? ?? '',
      assetId: json['assetId'] as String? ?? '',
      ahliWarisId: json['ahliWarisId'] as String? ?? '',
      percentage: (json['percentage'] as num? ?? 0).toDouble(),
      isExecutor: json['isExecutor'] as bool? ?? false,
      acknowledgedAt: json['acknowledgedAt'] != null
          ? DateTime.tryParse(json['acknowledgedAt'] as String)
          : null,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
