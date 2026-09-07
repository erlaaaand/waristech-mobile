import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/network/storage_upload_service.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/inheritance/presentation/providers/inheritance_provider.dart';
import 'package:wt_mobile/features/dashboard/presentation/widgets/confirm_upload_sheet.dart';
import 'package:wt_mobile/features/dashboard/presentation/widgets/lapor_info_card.dart';
import 'package:wt_mobile/features/dashboard/presentation/widgets/submit_success_view.dart';
import 'package:wt_mobile/features/dashboard/presentation/widgets/upload_area.dart';

// ---------------------------------------------------------------------------
// Provider untuk state upload
// ---------------------------------------------------------------------------

final _laporStateProvider =
    StateNotifierProvider.autoDispose<_LaporNotifier, _LaporState>(
      (ref) => _LaporNotifier(ref),
    );

class _LaporState {
  final PlatformFile? file;
  final String? uploadedUrl;
  final bool isUploading;
  final String? error;
  final bool isDone;

  const _LaporState({
    this.file,
    this.uploadedUrl,
    this.isUploading = false,
    this.error,
    this.isDone = false,
  });

  _LaporState copyWith({
    PlatformFile? file,
    String? uploadedUrl,
    bool? isUploading,
    String? error,
    bool? isDone,
  }) => _LaporState(
    file: file ?? this.file,
    uploadedUrl: uploadedUrl ?? this.uploadedUrl,
    isUploading: isUploading ?? this.isUploading,
    error: error,
    isDone: isDone ?? this.isDone,
  );
}

class _LaporNotifier extends StateNotifier<_LaporState> {
  final Ref _ref;
  final _uploadService = StorageUploadService();
  _LaporNotifier(this._ref) : super(const _LaporState());

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      state = state.copyWith(
        file: result.files.first,
        uploadedUrl: null,
        error: null,
      );
    }
  }

  /// Kirim laporan — [pewarisId] diturunkan otomatis dari
  /// myFamilyMembershipProvider (Pewaris yang mengundang Ahli Waris ini
  /// sudah diketahui sejak registrasi, tidak perlu diketik ulang manual).
  Future<void> submit(String pewarisId) async {
    if (state.file == null) {
      state = state.copyWith(error: 'Pilih dokumen terlebih dahulu.');
      return;
    }
    if (pewarisId.trim().isEmpty) {
      state = state.copyWith(
        error: 'Data Pewaris belum termuat. Coba lagi sebentar.',
      );
      return;
    }
    final file = state.file;
    if (file == null) {
      state = state.copyWith(error: 'Pilih dokumen terlebih dahulu.');
      return;
    }
    final bytes = file.bytes;
    if (bytes == null) {
      state = state.copyWith(error: 'Gagal membaca berkas yang dipilih.');
      return;
    }
    state = state.copyWith(isUploading: true, error: null);
    try {
      final url =
          state.uploadedUrl ??
          await _uploadService.uploadBytes(
            bytes,
            file.name,
            UploadPurpose.deathCertificate,
          );
      await _ref
          .read(submitDeathCertificateProvider.notifier)
          .submit(pewarisId: pewarisId.trim(), documentUrl: url);
      final submitState = _ref.read(submitDeathCertificateProvider);
      if (submitState.hasError) {
        state = state.copyWith(
          isUploading: false,
          uploadedUrl: url,
          error: submitState.error.toString(),
        );
        return;
      }
      state = state.copyWith(
        isUploading: false,
        uploadedUrl: url,
        isDone: true,
      );
    } catch (e) {
      state = state.copyWith(isUploading: false, error: e.toString());
    }
  }

  void reset() => state = const _LaporState();
}

// ---------------------------------------------------------------------------
// View
// ---------------------------------------------------------------------------

/// Tab Lapor Kematian — ajukan dokumen Akta Kematian resmi Dukcapil.
/// Backend: POST /storage/upload (purpose DEATH_CERTIFICATE) lalu
/// POST /inheritance/death-certificate.
class AhliWarisLaporView extends ConsumerStatefulWidget {
  const AhliWarisLaporView({super.key});

  @override
  ConsumerState<AhliWarisLaporView> createState() => _AhliWarisLaporViewState();
}

class _AhliWarisLaporViewState extends ConsumerState<AhliWarisLaporView> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(_laporStateProvider);
    final membershipAsync = ref.watch(myFamilyMembershipProvider);

    if (state.isDone) {
      return const SubmitSuccessView();
    }

    final entries = membershipAsync.valueOrNull
            ?.whereType<Map<String, dynamic>>()
            .toList() ??
        const <Map<String, dynamic>>[];
    final pewarisId = entries.isNotEmpty
        ? entries.first['pewarisId']?.toString()
        : null;
    final pewarisName = entries.isNotEmpty
        ? entries.first['pewarisName']?.toString()
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WtScreenHeader(label: 'Pelaporan', title: 'Unggah Akta'),
          const SizedBox(height: 24),
          const LaporInfoCard(),
          const SizedBox(height: 16),
          if (membershipAsync.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            )
          else if (pewarisId == null)
            const WtErrorBanner(
              message:
                  'Data Pewaris belum ditemukan. Pastikan Anda sudah terdaftar '
                  'sebagai Ahli Waris sebelum mengunggah akta.',
            )
          else
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      pewarisName != null && pewarisName.isNotEmpty
                          ? 'Dilaporkan untuk Pewaris: $pewarisName'
                          : 'Pewaris sudah teridentifikasi otomatis dari akun Anda.',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          UploadArea(
            file: state.file,
            onTap: () => ref.read(_laporStateProvider.notifier).pickFile(),
          ),
          if (state.error != null) ...[
            const SizedBox(height: 12),
            WtErrorBanner(
              message: state.error!,
              padding: const EdgeInsets.all(14),
              borderRadius: 14,
              iconSize: 20,
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 24),
          WtPrimaryButton(
            label: 'Kirim Dokumen',
            icon: Icons.send,
            isLoading: state.isUploading,
            onPressed: state.file != null && pewarisId != null
                ? () => _confirmAndSubmit(context, ref, pewarisId)
                : null,
          ),
        ],
      ),
    );
  }

  /// Konfirmasi eksplisit sebelum kirim — pengiriman akta memicu proses
  /// verifikasi hukum oleh Notaris dan tidak bisa dibatalkan begitu terkirim.
  Future<void> _confirmAndSubmit(
    BuildContext context,
    WidgetRef ref,
    String pewarisId,
  ) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const ConfirmUploadSheet(),
    );
    if (confirmed != true || !context.mounted) return;
    ref.read(_laporStateProvider.notifier).submit(pewarisId);
  }
}
