import 'package:flutter/material.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';

class SubmitSuccessView extends StatelessWidget {
  const SubmitSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Dokumen Terkirim!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            const Text(
              'Akta Kematian Anda telah diajukan dan menunggu tinjauan langsung oleh Notaris.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.gray600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
