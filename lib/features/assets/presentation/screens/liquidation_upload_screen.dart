import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/network/storage_upload_service.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/assets/presentation/providers/asset_provider.dart';

/// (Eksekutor) Unggah bukti pencairan e-Statement — POST
/// /assets/:id/liquidation-proof. Hanya berlaku saat status aset UNLOCKED;
/// sukses memindahkan aset ke LIQUIDATING menunggu tinjauan Notaris.
class LiquidationUploadScreen extends ConsumerStatefulWidget {
  final String assetId;
  final String assetName;
  const LiquidationUploadScreen({
    super.key,
    required this.assetId,
    required this.assetName,
  });

  @override
  ConsumerState<LiquidationUploadScreen> createState() =>
      _LiquidationUploadScreenState();
}

class _LiquidationUploadScreenState
    extends ConsumerState<LiquidationUploadScreen> {
  final _passwordCtrl = TextEditingController();
  final _uploadService = StorageUploadService();

  PlatformFile? _pickedFile;
  String? _uploadedUrl;
  bool _isUploading = false;
  bool _sptjmAgreed = false;
  String? _error;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    setState(() {
      _pickedFile = result.files.single;
      _uploadedUrl = null;
      _error = null;
    });
  }

  Future<void> _submit() async {
    if (_pickedFile == null) {
      setState(
        () => _error = 'Pilih dokumen e-Statement (PDF) terlebih dahulu.',
      );
      return;
    }
    if (!_sptjmAgreed) {
      setState(() => _error = 'Anda wajib menyetujui SPTJM sebelum mengirim.');
      return;
    }
    final file = _pickedFile;
    if (file == null) {
      setState(() => _error = 'Pilih dokumen terlebih dahulu.');
      return;
    }
    final bytes = file.bytes;
    if (bytes == null) {
      setState(() => _error = 'Gagal membaca berkas yang dipilih.');
      return;
    }

    setState(() {
      _isUploading = true;
      _error = null;
    });
    try {
      final url =
          _uploadedUrl ??
          await _uploadService.uploadBytes(
            bytes,
            file.name,
            UploadPurpose.other,
          );
      await ref
          .read(uploadLiquidationProofProvider(widget.assetId).notifier)
          .upload(
            assetId: widget.assetId,
            pdfFileUrl: url,
            pdfPassword: _passwordCtrl.text.trim().isEmpty
                ? null
                : _passwordCtrl.text.trim(),
            sptjmAgreed: _sptjmAgreed,
          );
      if (!mounted) return;
      final state = ref.read(uploadLiquidationProofProvider(widget.assetId));
      if (state.hasError) {
        setState(() {
          _isUploading = false;
          _uploadedUrl = url;
          _error = state.error.toString();
        });
        return;
      }
      if (!mounted) return;
      WtSnackbar.success(
        context,
        'Bukti pencairan berhasil diunggah — menunggu tinjauan Notaris.',
      );
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _isUploading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bukti Pencairan')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.assetName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Unggah PDF e-Statement resmi bank sebagai bukti dana telah '
                  'dicairkan. Keabsahan dokumen ditentukan manual oleh Notaris.',
                  style: TextStyle(fontSize: 12.5, height: 1.4),
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _isUploading ? null : _pickFile,
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: Text(_pickedFile?.name ?? 'Pilih Dokumen PDF'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordCtrl,
                decoration: InputDecoration(
                  labelText: 'Kata Sandi PDF (opsional)',
                  helperText: 'Isi bila dokumen terkunci oleh bank.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  filled: true,
                ),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: _sptjmAgreed,
                onChanged: (v) => setState(() => _sptjmAgreed = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Saya menyetujui Surat Pernyataan Tanggung Jawab Mutlak (SPTJM) '
                  'atas kebenaran bukti pencairan ini.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: const TextStyle(color: AppColors.danger, fontSize: 13),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text('Kirim Bukti Pencairan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
