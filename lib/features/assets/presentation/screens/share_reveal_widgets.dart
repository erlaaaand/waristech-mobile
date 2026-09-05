import 'package:flutter/material.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';

/// Panel opsional untuk menitipkan bagian kunci Notaris secara terenkripsi
/// (RSA public key Notaris) langsung dari layar ini.
class EscrowSection extends StatelessWidget {
  final TextEditingController notarisIdController;
  final bool isDone;
  final bool isEscrowing;
  final String? error;
  final VoidCallback onEscrow;

  const EscrowSection({
    super.key,
    required this.notarisIdController,
    required this.isDone,
    required this.isEscrowing,
    required this.error,
    required this.onEscrow,
  });

  @override
  Widget build(BuildContext context) {
    if (isDone) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Bagian kunci Notaris berhasil dititipkan (terenkripsi).',
                style: TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Titipkan ke Notaris Sekarang (Opsional)',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: notarisIdController,
            decoration: InputDecoration(
              labelText: 'ID Notaris (UUID)',
              helperText: 'Diperoleh dari Notaris yang menangani kasus Anda.',
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 8),
            Text(
              error!,
              style: const TextStyle(color: AppColors.danger, fontSize: 12),
            ),
          ],
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isEscrowing ? null : onEscrow,
              icon: isEscrowing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.lock_outline, size: 18),
              label: const Text('Enkripsi & Titipkan'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.amber,
                side: BorderSide(color: AppColors.amber.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Konfirmasi wajib sebelum layar boleh ditinggalkan — bagian kunci tidak
/// akan pernah ditampilkan lagi.
class ConfirmCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const ConfirmCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: value,
              onChanged: (v) => onChanged(v ?? false),
              activeColor: AppColors.success,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Saya sudah menyimpan kedua bagian kunci di atas dengan aman. '
                  'Saya paham nilai ini tidak akan ditampilkan lagi.',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Banner peringatan merah di atas layar — bagian kunci hanya ditampilkan
/// SEKALI, jadi peringatannya sengaja menonjol.
class WarningBanner extends StatelessWidget {
  final String warning;

  const WarningBanner(this.warning, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.danger),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              warning,
              style: const TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu satu bagian kunci Shamir: judul, penjelasan, nilai (monospace,
/// bisa diseleksi), dan tombol salin.
class ShareCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final Color color;
  final IconData icon;
  final void Function(String value, String label) onCopy;

  const ShareCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.color,
    required this.icon,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.w800, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(fontSize: 12.5, height: 1.4)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SelectableText(
              value,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11.5,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => onCopy(value, title),
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Salin'),
              style: TextButton.styleFrom(foregroundColor: color),
            ),
          ),
        ],
      ),
    );
  }
}
