import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/crypto/rsa_keypair_service.dart';
import 'package:wt_mobile/core/crypto/shamir_secret_sharing.dart';
import 'package:wt_mobile/core/storage/secure_key_share_storage.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/utils/clipboard_utils.dart';
import 'package:wt_mobile/features/assets/presentation/providers/asset_provider.dart';
import 'package:wt_mobile/features/users/presentation/providers/user_provider.dart';

/// (Pewaris) Rotasi bagian kunci aset — POST /assets/:id/rotate-shares.
///
/// Server TIDAK BISA merekonstruksi kredensial, sehingga seluruh alur
/// digerakkan di klien: (1) kumpulkan 2 bagian kunci yang lama, (2) gabungkan
/// jadi rahasia asli, (3) pecah ULANG jadi 3 bagian BARU (Fase 0), (4) kirim
/// bagian SYSTEM baru ke server. Bagian lama langsung tidak berlaku begitu
/// server menerima yang baru.
class RotateKeySharesScreen extends ConsumerStatefulWidget {
  final String assetId;
  final String assetName;
  const RotateKeySharesScreen({
    super.key,
    required this.assetId,
    required this.assetName,
  });

  @override
  ConsumerState<RotateKeySharesScreen> createState() =>
      _RotateKeySharesScreenState();
}

class _RotateKeySharesScreenState extends ConsumerState<RotateKeySharesScreen> {
  final _share1Ctrl = TextEditingController();
  final _share2Ctrl = TextEditingController();
  final _notarisIdCtrl = TextEditingController();
  bool _reescrowToNotaris = false;

  bool _isProcessing = false;
  String? _error;
  ({String executorShare, String notarisShare})? _newShares;

  @override
  void initState() {
    super.initState();
    _prefillLocalShare();
  }

  Future<void> _prefillLocalShare() async {
    final local = await SecureKeyShareStorage.readExecutorShare(widget.assetId);
    if (local != null && local.isNotEmpty && mounted) {
      setState(() => _share1Ctrl.text = local);
    }
  }

  @override
  void dispose() {
    _share1Ctrl.dispose();
    _share2Ctrl.dispose();
    _notarisIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _rotate() async {
    final share1 = _share1Ctrl.text.trim();
    final share2 = _share2Ctrl.text.trim();
    if (share1.isEmpty || share2.isEmpty) {
      setState(() => _error = 'Kedua bagian kunci wajib diisi.');
      return;
    }
    setState(() {
      _isProcessing = true;
      _error = null;
    });
    try {
      // 1) Rekonstruksi rahasia asli dari 2 bagian yang dipegang klien.
      final combinedHex = ShamirSecretSharing.combine([share1, share2]);
      final plaintext = ShamirSecretSharing.hex2str(combinedHex);

      // 2) Pecah ULANG jadi 3 bagian baru (2-dari-3), simetris seperti backend.
      final newHex = ShamirSecretSharing.str2hex(plaintext);
      final newShares = ShamirSecretSharing.share(newHex, 3, 2);
      final newExecutorShare = newShares[0];
      final newNotarisShare = newShares[1];
      final newSystemShare = newShares[2];

      String? newNotarisEncryptedShare;
      if (_reescrowToNotaris) {
        final notarisId = _notarisIdCtrl.text.trim();
        if (notarisId.isEmpty) {
          throw Exception('ID Notaris wajib diisi untuk titip ulang.');
        }
        final keyInfo = await fetchNotarisPublicKey(notarisId);
        final publicKeyPem = keyInfo['publicKey'] as String? ?? '';
        if (publicKeyPem.isEmpty) {
          throw Exception('Notaris ini belum mendaftarkan kunci publik.');
        }
        newNotarisEncryptedShare = RsaKeypairService.encryptWithPublicKeyPem(
          newNotarisShare,
          publicKeyPem,
        );
      }

      // 3) Kirim bagian SYSTEM baru ke server — bagian lama langsung tidak berlaku.
      await ref
          .read(assetRepositoryProvider)
          .rotateKeyShares(
            assetId: widget.assetId,
            newSystemShare: newSystemShare,
            newNotarisEncryptedShare: newNotarisEncryptedShare,
          );

      // 4) Simpan bagian Eksekutor BARU secara lokal — bagian lama sudah using habis.
      await SecureKeyShareStorage.saveExecutorShare(
        widget.assetId,
        newExecutorShare,
      );

      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _newShares = (
          executorShare: newExecutorShare,
          notarisShare: newNotarisShare,
        );
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _newShares;
    return Scaffold(
      appBar: AppBar(title: Text('Rotasi Kunci — ${widget.assetName}')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: result != null
              ? _RotateResultView(
                  result: result,
                  onCopy: (value, label) =>
                      copyToClipboard(context, value, label),
                )
              : _RotateFormView(
                  share1Controller: _share1Ctrl,
                  share2Controller: _share2Ctrl,
                  notarisIdController: _notarisIdCtrl,
                  reescrowToNotaris: _reescrowToNotaris,
                  onReescrowChanged: (v) =>
                      setState(() => _reescrowToNotaris = v),
                  error: _error,
                  isProcessing: _isProcessing,
                  onRotate: _rotate,
                ),
        ),
      ),
    );
  }
}

/// Formulir rotasi: dua bagian kunci lama + opsi titip ulang ke Notaris.
class _RotateFormView extends StatelessWidget {
  final TextEditingController share1Controller;
  final TextEditingController share2Controller;
  final TextEditingController notarisIdController;
  final bool reescrowToNotaris;
  final ValueChanged<bool> onReescrowChanged;
  final String? error;
  final bool isProcessing;
  final VoidCallback onRotate;

  const _RotateFormView({
    required this.share1Controller,
    required this.share2Controller,
    required this.notarisIdController,
    required this.reescrowToNotaris,
    required this.onReescrowChanged,
    required this.error,
    required this.isProcessing,
    required this.onRotate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Text(
            'Gunakan bila khawatir salah satu bagian kunci lama bocor. Isi dua '
            'bagian kunci yang Anda pegang (mis. bagian Eksekutor lokal + '
            'bagian yang diserahkan Notaris) untuk merekonstruksi dan memecah '
            'ulang kredensial. Bagian lama langsung tidak berlaku.',
            style: TextStyle(fontSize: 12.5, height: 1.4),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: share1Controller,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: 'Bagian Kunci 1',
            helperText: 'Terisi otomatis bila tersimpan di perangkat ini.',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            filled: true,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: share2Controller,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: 'Bagian Kunci 2',
            helperText: 'Mis. bagian Notaris atau Eksekutor lain yang diperoleh manual.',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            filled: true,
          ),
        ),
        const SizedBox(height: 12),
        CheckboxListTile(
          value: reescrowToNotaris,
          onChanged: (v) => onReescrowChanged(v ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'Titipkan ulang bagian baru ke Notaris',
            style: TextStyle(fontSize: 13.5),
          ),
        ),
        if (reescrowToNotaris) ...[
          const SizedBox(height: 4),
          TextField(
            controller: notarisIdController,
            decoration: InputDecoration(
              labelText: 'ID Notaris (UUID)',
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
            ),
          ),
        ],
        if (error != null) ...[
          const SizedBox(height: 12),
          Text(
            error!,
            style: const TextStyle(color: AppColors.danger, fontSize: 13),
          ),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isProcessing ? null : onRotate,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text('Gabungkan & Rotasi'),
          ),
        ),
      ],
    );
  }
}

/// Hasil rotasi: dua bagian kunci BARU yang hanya ditampilkan di sini.
class _RotateResultView extends StatelessWidget {
  final ({String executorShare, String notarisShare}) result;
  final void Function(String value, String label) onCopy;

  const _RotateResultView({required this.result, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Text(
            'Rotasi berhasil. Bagian kunci lama sudah tidak berlaku. Bagian '
            'Eksekutor baru sudah tersimpan di perangkat ini — teruskan bagian '
            'di bawah ke Ahli Waris yang Anda tunjuk sebagai Eksekutor.',
            style: TextStyle(
              color: AppColors.success,
              fontSize: 12.5,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _ShareBox(
          label: 'Bagian Kunci Eksekutor (Baru)',
          value: result.executorShare,
          onCopy: onCopy,
        ),
        const SizedBox(height: 12),
        _ShareBox(
          label: 'Bagian Kunci Notaris (Baru)',
          value: result.notarisShare,
          onCopy: onCopy,
        ),
      ],
    );
  }
}

/// Kotak satu bagian kunci beserta tombol salin.
class _ShareBox extends StatelessWidget {
  final String label;
  final String value;
  final void Function(String value, String label) onCopy;

  const _ShareBox({
    required this.label,
    required this.value,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          ),
          const SizedBox(height: 8),
          SelectableText(
            value,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11.5),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => onCopy(value, label),
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Salin'),
            ),
          ),
        ],
      ),
    );
  }
}
