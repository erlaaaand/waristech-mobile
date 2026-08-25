// lib/features/assets/domain/entities/asset_entity.dart
// Plain Dart class (no code generation needed)

enum AssetType {
  crypto,
  bank,
  ewallet,
  socialMedia,
  other;

  static AssetType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'CRYPTO': return AssetType.crypto;
      case 'BANK': return AssetType.bank;
      case 'EWALLET': return AssetType.ewallet;
      case 'SOCIAL_MEDIA': return AssetType.socialMedia;
      default: return AssetType.other;
    }
  }

  String get displayName {
    switch (this) {
      case AssetType.crypto: return 'Crypto';
      case AssetType.bank: return 'Bank';
      case AssetType.ewallet: return 'E-Wallet';
      case AssetType.socialMedia: return 'Media Sosial';
      case AssetType.other: return 'Lainnya';
    }
  }
}

enum AssetStatus {
  pending,
  verified,
  rejected,
  distributed,
  closed;

  static AssetStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'VERIFIED': return AssetStatus.verified;
      case 'REJECTED': return AssetStatus.rejected;
      case 'DISTRIBUTED': return AssetStatus.distributed;
      case 'CLOSED': return AssetStatus.closed;
      default: return AssetStatus.pending;
    }
  }
}

class AssetEntity {
  final String id;
  final String pewarisId;
  final AssetType type;
  final String assetName;
  final String platform;
  final String accountIdentifier;
  final AssetStatus status;
  final DateTime createdAt;

  const AssetEntity({
    required this.id,
    required this.pewarisId,
    required this.type,
    required this.assetName,
    required this.platform,
    required this.accountIdentifier,
    required this.status,
    required this.createdAt,
  });

  factory AssetEntity.fromJson(Map<String, dynamic> json) {
    return AssetEntity(
      id: json['id'] as String? ?? '',
      pewarisId: json['pewarisId'] as String? ?? '',
      type: AssetType.fromString(json['type'] as String? ?? ''),
      assetName: json['assetName'] as String? ?? '',
      platform: json['platform'] as String? ?? '',
      accountIdentifier: json['accountIdentifier'] as String? ?? '',
      status: AssetStatus.fromString(json['status'] as String? ?? ''),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
