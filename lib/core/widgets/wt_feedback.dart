import 'package:flutter/material.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';

/// Banner error merah standar (ikon + pesan) — sebelumnya didefinisikan
/// ulang secara identik di banyak file `*_components.dart` sebagai
/// `class ErrorBanner`. Parameter opsional menampung sedikit variasi gaya
/// yang sebelumnya ada di masing-masing salinan.
class WtErrorBanner extends StatelessWidget {
  final String message;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double? iconSize;
  final TextStyle? textStyle;

  const WtErrorBanner({
    super.key,
    required this.message,
    this.margin = EdgeInsets.zero,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16,
    this.iconSize,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.danger, size: iconSize),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: (textStyle ?? const TextStyle()).copyWith(
                  color: AppColors.danger,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder "belum ada data" standar (ikon opsional + pesan + subjudul
/// opsional) — sebelumnya didefinisikan ulang di banyak file sebagai
/// `EmptyState`/`EmptyQueue`/`EmptyHeirs`/`EmptyUpload` dengan bentuk yang
/// sama persis.
class WtEmptyState extends StatelessWidget {
  final String message;
  final String? subtitle;
  final IconData? icon;
  final double iconSize;
  final Color? iconColor;
  final TextStyle? messageStyle;
  final EdgeInsetsGeometry padding;

  const WtEmptyState({
    super.key,
    required this.message,
    this.subtitle,
    this.icon,
    this.iconSize = 48,
    this.iconColor,
    this.messageStyle,
    this.padding = const EdgeInsets.all(32),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: iconSize, color: iconColor ?? AppColors.primaryLight),
              const SizedBox(height: 12),
            ],
            Text(
              message,
              textAlign: TextAlign.center,
              style: messageStyle ?? const TextStyle(color: AppColors.gray500),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.gray500, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Helper `SnackBar` standar — sebelumnya `ScaffoldMessenger.of(context)
/// .showSnackBar(SnackBar(...))` ditulis ulang manual di banyak layar untuk
/// dua kasus yang sama: pesan error (merah) dan pesan sukses (default).
class WtSnackbar {
  const WtSnackbar._();

  static void error(
    BuildContext context,
    String message, {
    ShapeBorder? shape,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: shape,
      ),
    );
  }

  static void success(
    BuildContext context,
    String message, {
    ShapeBorder? shape,
    // null = tema default (kebanyakan layar) — isi mis. AppColors.success
    // untuk varian sukses yang sengaja diberi latar hijau.
    Color? backgroundColor,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: shape,
        backgroundColor: backgroundColor,
      ),
    );
  }
}

/// Dialog konfirmasi standar (judul + pesan + tombol batal/konfirmasi terisi
/// warna) — sebelumnya `AlertDialog` dengan bentuk yang sama (`TextButton`
/// batal + `ElevatedButton` berwarna untuk konfirmasi) ditulis ulang manual
/// di banyak layar untuk aksi seperti tolak/hapus/lanjutkan.
class WtConfirmDialog {
  const WtConfirmDialog._();

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    String cancelLabel = 'Batal',
    // null = pakai warna tombol default tema (mis. konfirmasi netral seperti
    // "Buat Keypair Baru?"); isi mis. AppColors.danger untuk aksi destruktif.
    Color? confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelLabel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: confirmColor == null
                ? null
                : ElevatedButton.styleFrom(
                    backgroundColor: confirmColor,
                    foregroundColor: Colors.white,
                  ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
