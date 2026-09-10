import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/utils/phone_number_utils.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/inheritance/presentation/providers/inheritance_provider.dart';

const int _kMinimumWitnessCount = 3;

/// Kelola Saksi/Kontak Darurat — POST/GET /inheritance/witnesses.
/// Minimal 3 saksi diperlukan sebelum verifikasi kematian dapat diproses
/// (lihat modul Verifikasi Berjenjang backend).
class WitnessManagementScreen extends ConsumerStatefulWidget {
  const WitnessManagementScreen({super.key});

  @override
  ConsumerState<WitnessManagementScreen> createState() =>
      _WitnessManagementScreenState();
}

class _WitnessManagementScreenState
    extends ConsumerState<WitnessManagementScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState?.validate() != true) return;
    await ref
        .read(registerWitnessProvider.notifier)
        .register(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          phone: PhoneNumberUtils.normalize(_phoneCtrl.text.trim()) ??
              _phoneCtrl.text.trim(),
        );
    if (!mounted) return;
    final state = ref.read(registerWitnessProvider);
    if (state.hasError) {
      WtSnackbar.error(context, state.error.toString());
      return;
    }
    _nameCtrl.clear();
    _emailCtrl.clear();
    _phoneCtrl.clear();
    WtSnackbar.success(context, 'Saksi berhasil didaftarkan.');
  }

  @override
  Widget build(BuildContext context) {
    final witnessesAsync = ref.watch(witnessesProvider);
    final isSaving = ref.watch(registerWitnessProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Saksi / Kontak Darurat')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WtInfoCard(
                icon: Icons.info_outline,
                iconColor: AppColors.amber,
                title: 'Minimal 3 Saksi Diperlukan',
                description: 'Diperlukan sebelum verifikasi kematian dapat diproses. Saksi HARUS pihak non-ahli waris (mis. teman dekat, kolega).',
                padding: EdgeInsets.all(16),
                tinted: true,
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daftarkan Saksi Baru',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    WtFormField(
                      label: 'Nama',
                      controller: _nameCtrl,
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 10),
                    WtFormField(
                      label: 'Email',
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 10),
                    WtFormField(
                      label: 'Nomor Telepon',
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      hintText: '081234567890',
                      validator: PhoneNumberUtils.validator,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Daftarkan',
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
              const SizedBox(height: 28),
              witnessesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text(
                  e.toString(),
                  style: const TextStyle(color: AppColors.danger),
                ),
                data: (items) => _WitnessList(items),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Daftar saksi terdaftar beserta cincin progres menuju jumlah minimum.
class _WitnessList extends StatelessWidget {
  final List<dynamic> items;

  const _WitnessList(this.items);

  @override
  Widget build(BuildContext context) {
    final progress = (items.length / _kMinimumWitnessCount).clamp(0.0, 1.0);
    final isEnough = items.length >= _kMinimumWitnessCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            WtAnimatedProgressRing(
              value: progress,
              size: 44,
              strokeWidth: 4.5,
              color: isEnough ? AppColors.success : AppColors.primary,
              child: Text(
                '${items.length}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: isEnough ? AppColors.success : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Saksi Terdaftar (${items.length}/$_kMinimumWitnessCount minimum)',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          const Text(
            'Belum ada saksi terdaftar.',
            style: TextStyle(color: AppColors.gray500),
          )
        else
          ...items.whereType<Map<String, dynamic>>().map((w) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            // Nilai persis enum WitnessStatus backend: PENDING/APPROVE/DISPUTE
            // (dulu dibandingkan dengan 'APPROVED' sehingga saksi yang sudah
            // setuju tetap tampil "Menunggu").
            final status = w['status']?.toString() ?? 'PENDING';
            final (statusLabel, statusColor) = switch (status) {
              'APPROVE' => ('Disetujui', AppColors.success),
              'DISPUTE' => ('Menyanggah', AppColors.danger),
              _ => ('Menunggu', AppColors.amber),
            };
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: WtSurfaceCard(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        (w['name']?.toString().isNotEmpty ?? false)
                            ? w['name'].toString()[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            w['name']?.toString() ?? '-',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            w['email']?.toString() ?? '-',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.4)
                                  : AppColors.navy.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    WtStatusBadge(
                      label: statusLabel,
                      color: statusColor,
                      dot: true,
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}

/// Validator wajib-isi dipakai beberapa field pada layar ini.
String? _requiredValidator(String? v) =>
    (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null;
