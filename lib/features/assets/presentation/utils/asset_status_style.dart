import 'package:flutter/material.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/features/assets/domain/entities/asset_entity.dart';

/// Pemetaan `AssetStatus`/`AssetType` ke elemen visual (warna, ikon).
///
/// Ditaruh di presentation layer (bukan getter di entity domain) supaya
/// domain tetap bebas dari dependensi Flutter — lihat `AssetStatus`/
/// `AssetType` di `asset_entity.dart` yang murni Dart. Sebelumnya switch
/// yang sama ditulis ulang di beberapa widget (`ahli_waris_brankas_
/// components.dart`, `aset_components.dart`); sekarang satu tempat.
extension AssetStatusStyle on AssetStatus {
  /// Warna badge status berdasarkan tahap siklus hidup brankas aset.
  Color get color {
    switch (this) {
      case AssetStatus.unlocked:
      case AssetStatus.distributed:
        return AppColors.success;
      case AssetStatus.frozen:
      case AssetStatus.disputedLiquidation:
      case AssetStatus.rejected:
        return AppColors.danger;
      case AssetStatus.pendingCooldown:
      case AssetStatus.liquidating:
        return AppColors.amber;
      default:
        return AppColors.primary;
    }
  }
}

extension AssetTypeStyle on AssetType {
  IconData get icon {
    switch (this) {
      case AssetType.crypto:
        return Icons.currency_bitcoin;
      case AssetType.saham:
        return Icons.show_chart;
      case AssetType.reksaDana:
        return Icons.pie_chart_outline;
      case AssetType.obligasi:
        return Icons.receipt_long_outlined;
      case AssetType.eWallet:
        return Icons.account_balance_wallet_outlined;
      case AssetType.rekeningBank:
        return Icons.account_balance_outlined;
      case AssetType.asuransiJiwa:
        return Icons.health_and_safety_outlined;
      case AssetType.p2pLending:
        return Icons.handshake_outlined;
      case AssetType.emasDigital:
        return Icons.star_border;
      case AssetType.nft:
        return Icons.image_outlined;
      case AssetType.domainWebsite:
        return Icons.language_outlined;
      case AssetType.lainnya:
        return Icons.inventory_2_outlined;
    }
  }
}
