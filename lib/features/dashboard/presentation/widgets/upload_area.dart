import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';

class UploadArea extends StatelessWidget {
  final PlatformFile? file;
  final VoidCallback onTap;

  const UploadArea({super.key, required this.file, required this.onTap});

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
              ? AppColors.success.withValues(alpha: 0.05)
              : (isDark ? AppColors.darkCard : AppColors.warm),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasFile
                ? AppColors.success.withValues(alpha: 0.4)
                : (isDark ? Colors.white : AppColors.navy).withValues(
                    alpha: 0.15,
                  ),
            width: 2,
          ),
        ),
        child: hasFile ? FilePreview(file: file!) : const EmptyUpload(),
      ),
    );
  }
}

class EmptyUpload extends StatelessWidget {
  const EmptyUpload({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Icon(
          Icons.document_scanner,
          size: 40,
          color: (isDark ? Colors.white : AppColors.navy).withValues(
            alpha: 0.4,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Ketuk untuk Pilih Dokumen',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'JPG, PNG, atau PDF — Maks 20MB',
          style: TextStyle(
            fontSize: 12,
            color: (isDark ? Colors.white : AppColors.navy).withValues(
              alpha: 0.45,
            ),
          ),
        ),
      ],
    );
  }
}

class FilePreview extends StatelessWidget {
  final PlatformFile file;
  const FilePreview({super.key, required this.file});

  String get _size {
    final kb = (file.size / 1024).toStringAsFixed(1);
    return '$kb KB';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.insert_drive_file, color: AppColors.success),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                file.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _size,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.check_circle, color: AppColors.success),
      ],
    );
  }
}
