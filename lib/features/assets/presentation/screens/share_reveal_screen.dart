import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wt_mobile/core/crypto/rsa_keypair_service.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/utils/clipboard_utils.dart';
import 'package:wt_mobile/features/assets/domain/entities/create_asset_result_entity.dart';
import 'package:wt_mobile/features/assets/presentation/providers/asset_provider.dart';
import 'package:wt_mobile/features/assets/presentation/screens/share_reveal_widgets.dart';
import 'package:wt_mobile/features/users/presentation/providers/user_provider.dart';

/// Menampilkan bagian kunci Eksekutor & Notaris SATU KALI setelah aset VAULT
/// dibuat. Server tidak pernah menyimpan atau mengirim ulang nilai ini.
///
/// Bagian Eksekutor SUDAH otomatis disimpan ke secure storage sebelum layar
/// ini muncul (lihat `CreateAssetNotifier.create`) — reveal di sini murni
/// agar Pewaris bisa membuat cadangan manual (tulis di kertas, dsb.) dan
/// meneruskan bagian Notaris secara aman.
///
/// Navigasi keluar (termasuk tombol back perangkat) DIKUNCI sampai pengguna
/// menegaskan sudah menyimpan kedua bagian ini.
class ShareRevealScreen extends ConsumerStatefulWidget {
  final CreateAssetResultEntity result;
  const ShareRevealScreen({super.key, required this.result});

  @override
  ConsumerState<ShareRevealScreen> createState() => _ShareRevealScreenState();
}

class _ShareRevealScreenState extends ConsumerState<ShareRevealScreen> {
  bool _confirmed = false;
  final _notarisIdCtrl = TextEditingController();
  bool _isEscrowing = false;
  String? _escrowError;
  bool _escrowDone = false;

  @override
  void dispose() {
    _notarisIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _escrowToNotaris() async {
    final notarisId = _notarisIdCtrl.text.trim();
    final notarisShare = widget.result.notarisShare;
    if (notarisId.isEmpty) {
      setState(() => _escrowError = 'ID Notaris wajib diisi.');
      return;
    }
    if (notarisShare == null || notarisShare.isEmpty) {
      setState(() => _escrowError = 'Bagian kunci Notaris tidak tersedia.');
      return;
    }
    setState(() {
      _isEscrowing = true;
      _escrowError = null;
    });
    try {
      final keyInfo = await fetchNotarisPublicKey(notarisId);
      final publicKeyPem = keyInfo['publicKey'] as String? ?? '';
      if (publicKeyPem.isEmpty) {
        throw Exception('Notaris ini belum mendaftarkan kunci publik.');
      }
      final encryptedShare = RsaKeypairService.encryptWithPublicKeyPem(
        notarisShare,
        publicKeyPem,
      );
      await ref
          .read(assetRepositoryProvider)
          .escrowNotarisShare(
            assetId: widget.result.asset.id,
            notarisId: notarisId,
            encryptedShare: encryptedShare,
          );
      if (!mounted) return;
      setState(() {
        _isEscrowing = false;
        _escrowDone = true;
      });
    } catch (e) {
      setState(() {
        _isEscrowing = false;
        _escrowError = e.toString();
      });
    }
  }

  void _finish() {
    // Kembali ke dashboard — daftar aset sudah di-invalidate oleh provider.
    context.goNamed('pewaris-dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;

    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Simpan Bagian Kunci'),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WarningBanner(r.warning),
                const SizedBox(height: 20),
                Text(
                  'Aset: ${r.asset.assetName}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                ShareCard(
                  onCopy: (value, label) =>
                      copyToClipboard(context, value, label),
                  title: 'Bagian Kunci Eksekutor',
                  subtitle:
                      'Sudah otomatis tersimpan aman di perangkat ini. Simpan '
                      'juga salinan manual (mis. dicetak) lalu teruskan ke '
                      'Ahli Waris yang akan Anda tunjuk sebagai Eksekutor.',
                  value: r.executorShare ?? '',
                  color: AppColors.primary,
                  icon: Icons.smartphone,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Kunci Notaris Terkirim',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.success,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Bagian kunci Notaris telah otomatis diamankan, dienkripsi, dan dititipkan ke Notaris pilihan Anda.',
                              style: TextStyle(
                                fontSize: 12.5,
                                height: 1.4,
                                color: AppColors.success.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _finish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.primary.withValues(
                        alpha: 0.3,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Selesai',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
