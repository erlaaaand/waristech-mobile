import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wt_mobile/core/widgets/wt_feedback.dart';

/// Salin [value] ke clipboard lalu tampilkan snackbar konfirmasi berlabel
/// [label] — sebelumnya `Clipboard.setData` + `ScaffoldMessenger...
/// showSnackBar` ditulis ulang manual di beberapa tempat (kartu kredensial
/// brankas, layar reveal kunci).
Future<void> copyToClipboard(
  BuildContext context,
  String value,
  String label,
) async {
  await Clipboard.setData(ClipboardData(text: value));
  if (!context.mounted) return;
  WtSnackbar.success(context, '$label disalin.');
}
