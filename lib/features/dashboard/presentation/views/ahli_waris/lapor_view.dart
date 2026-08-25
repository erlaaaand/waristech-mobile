import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';

// ---------------------------------------------------------------------------
// Provider untuk state upload
// ---------------------------------------------------------------------------

final _laporStateProvider =
    StateNotifierProvider.autoDispose<_LaporNotifier, _LaporState>(
  (ref) => _LaporNotifier(),
);

class _LaporState {
  final PlatformFile? file;
  final bool isUploading;
  final String? error;
  final bool isDone;

  const _LaporState({
    this.file,
    this.isUploading = false,
    this.error,
    this.isDone = false,
  });

  _LaporState copyWith({
    PlatformFile? file,
    bool? isUploading,
    String? error,
    bool? isDone,
  }) =>
      _LaporState(
        file: file ?? this.file,
        isUploading: isUploading ?? this.isUploading,
        error: error,
        isDone: isDone ?? this.isDone,
      );
}

class _LaporNotifier extends StateNotifier<_LaporState> {
  _LaporNotifier() : super(const _LaporState());

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      withData: false,
      withReadStream: true,
    );
    if (result != null && result.files.isNotEmpty) {
      state = state.copyWith(file: result.files.first, error: null);
    }
  }

  Future<void> submit() async {
    if (state.file == null) {
      state = state.copyWith(error: 'Pilih dokumen terlebih dahulu.');
      return;
    }
    state = state.copyWith(isUploading: true, error: null);

    // TODO: Kirim ke endpoint POST /death-reports dengan multipart
    await Future.delayed(const Duration(seconds: 2)); // simulasi

    state = state.copyWith(isUploading: false, isDone: true);
  }

  void reset() => state = const _LaporState();
}

// ---------------------------------------------------------------------------
// View
// ---------------------------------------------------------------------------

/// Tab Lapor Kematian — upload dokumen Akta Kematian / e-Statement.
class AhliWarisLaporView extends ConsumerWidget {
  const AhliWarisLaporView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(_laporStateProvider);

    if (state.isDone) {
      return const _SubmitSuccessView();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WtSectionTitle('Pelaporan'),
          const SizedBox(height: 4),
          const Text('Unggah Akta', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          const SizedBox(height: 24),
          _InfoCard(),
          const SizedBox(height: 16),
          _UploadArea(
            file: state.file,
            onTap: () => ref.read(_laporStateProvider.notifier).pickFile(),
          ),
          if (state.error != null) ...[
            const SizedBox(height: 12),
            _ErrorBanner(message: state.error!),
          ],
          const SizedBox(height: 24),
          WtPrimaryButton(
            label: 'Kirim Dokumen',
            icon: Icons.send,
            isLoading: state.isUploading,
            onPressed: state.file != null
                ? () => ref.read(_laporStateProvider.notifier).submit()
                : null,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _InfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.info_outline, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Dokumen Resmi Dukcapil / e-Statement', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(
                  'Unggah foto atau scan Akta Kematian resmi. Dokumen ini akan diekstraksi oleh AI Forensic Validator sebelum diverifikasi oleh Notaris.',
                  style: TextStyle(fontSize: 12, color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.6), height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadArea extends StatelessWidget {
  final PlatformFile? file;
  final VoidCallback onTap;

  const _UploadArea({required this.file, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasFile = file != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: hasFile
              ? AppColors.success.withOpacity(0.05)
              : (isDark ? AppColors.darkCard : AppColors.warm),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasFile
                ? AppColors.success.withOpacity(0.4)
                : (isDark ? Colors.white : AppColors.navy).withOpacity(0.15),
            width: 2,
          ),
        ),
        child: hasFile
            ? _FilePreview(file: file!)
            : _EmptyUpload(),
      ),
    );
  }
}

class _EmptyUpload extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Icon(Icons.document_scanner, size: 40, color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.3)),
        const SizedBox(height: 10),
        const Text('Ketuk untuk Pilih Dokumen', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('JPG, PNG, atau PDF — Maks 5MB', style: TextStyle(fontSize: 12, color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.45))),
      ],
    );
  }
}

class _FilePreview extends StatelessWidget {
  final PlatformFile file;
  const _FilePreview({required this.file});

  String get _size {
    final kb = (file.size / 1024).toStringAsFixed(1);
    return '${kb} KB';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.insert_drive_file, color: AppColors.success),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(file.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(_size, style: const TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const Icon(Icons.check_circle, color: AppColors.success),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.08), borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: const TextStyle(color: AppColors.danger, fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

class _SubmitSuccessView extends StatelessWidget {
  const _SubmitSuccessView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle, color: AppColors.success, size: 40),
            ),
            const SizedBox(height: 24),
            const Text('Dokumen Terkirim!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Text(
              'Akta Kematian Anda sedang diproses oleh AI Forensic Validator. Pantau status verifikasi di tab Lacak.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
