import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/network/storage_upload_service.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/utils/clipboard_utils.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/inheritance/presentation/providers/inheritance_provider.dart';

/// Buat & kelola link undangan Ahli Waris — GET/POST /inheritance/invitations.
///
/// Mekanisme resmi: Pewaris generate link di sini, lalu membagikannya sendiri
/// (WhatsApp/email/dsb — sistem TIDAK mengirim otomatis). Membuka link
/// tersebut mengarahkan Ahli Waris langsung ke layar registrasi dengan kode
/// SUDAH TERISI otomatis — bukan lagi mengetik kode manual dari mana pun.
class InvitationsScreen extends ConsumerStatefulWidget {
  const InvitationsScreen({super.key});

  @override
  ConsumerState<InvitationsScreen> createState() => _InvitationsScreenState();
}

/// Sekadar saran cepat untuk mengisi field teks bebas `relationshipDescription`
/// — backend TIDAK punya enum tertutup untuk ini, jadi memilih salah satu
/// hanya mengisi teksnya, tidak mengunci field.
const _relationSuggestions = [
  'Istri',
  'Suami',
  'Anak Laki-laki',
  'Anak Perempuan',
  'Ayah Kandung',
  'Ibu Kandung',
  'Saudara Kandung',
];

class _InvitationsScreenState extends ConsumerState<InvitationsScreen> {
  final _relationshipDescCtrl = TextEditingController();
  final _uploadService = StorageUploadService();
  String _relationshipType = 'NASAB';
  String? _supportingDocumentUrl;
  bool _isUploadingDoc = false;

  @override
  void dispose() {
    _relationshipDescCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickSupportingDocument() async {
    setState(() => _isUploadingDoc = true);
    try {
      final url = await _uploadService.pickAndUpload(
        UploadPurpose.familyDocument,
      );
      if (!mounted) return;
      setState(() => _supportingDocumentUrl = url);
    } catch (e) {
      if (!mounted) return;
      WtSnackbar.error(context, 'Gagal mengunggah dokumen: $e');
    } finally {
      if (mounted) setState(() => _isUploadingDoc = false);
    }
  }

  Future<void> _generate() async {
    if (_relationshipDescCtrl.text.trim().isEmpty) {
      WtSnackbar.error(
        context,
        'Deskripsi hubungan wajib diisi (mis. "Anak kandung").',
      );
      return;
    }
    if (_relationshipType == 'NON_NASAB' && _supportingDocumentUrl == null) {
      WtSnackbar.error(
        context,
        'Hubungan Non-Nasab wajib menyertakan dokumen pendukung (Surat Wasiat/Hibah).',
      );
      return;
    }

    await ref
        .read(generateInvitationProvider.notifier)
        .generate(
          relationshipType: _relationshipType,
          relationshipDescription: _relationshipDescCtrl.text.trim(),
          supportingDocumentUrl: _supportingDocumentUrl,
        );
    final state = ref.read(generateInvitationProvider);
    if (!mounted) return;
    if (state.error != null) {
      WtSnackbar.error(context, state.error!);
      return;
    }
    _relationshipDescCtrl.clear();
    setState(() {
      _supportingDocumentUrl = null;
      _relationshipType = 'NASAB';
    });
    ref.invalidate(invitationsProvider);
    ref.read(generateInvitationProvider.notifier).reset();
    WtSnackbar.success(context, 'Link undangan berhasil dibuat.');
  }

  @override
  Widget build(BuildContext context) {
    final invitationsAsync = ref.watch(invitationsProvider);
    final generateState = ref.watch(generateInvitationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Undangan Ahli Waris')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WtScreenHeader(
                label: 'Pelapor',
                title: 'Undang Ahli Waris',
              ),
              const SizedBox(height: 8),
              Text(
                'Bagikan link yang dihasilkan lewat kanal apa pun (WhatsApp, email, dsb). '
                'Ahli Waris tinggal membuka link — kode undangan sudah terisi otomatis.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.4)
                      : AppColors.navy.withValues(alpha: 0.6),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              WtFormField(
                label: 'Deskripsi Hubungan',
                controller: _relationshipDescCtrl,
                hintText: 'mis. "Anak kandung pertama"',
              ),
              const SizedBox(height: 10),
              WtSuggestionChips(
                options: _relationSuggestions,
                selected: _relationshipDescCtrl.text,
                onSelected: (v) =>
                    setState(() => _relationshipDescCtrl.text = v),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: WtRadioListTile<String>(
                      value: 'NASAB',
                      groupValue: _relationshipType,
                      title: 'NASAB',
                      onChanged: (v) => setState(() => _relationshipType = v!),
                    ),
                  ),
                  Expanded(
                    child: WtRadioListTile<String>(
                      value: 'NON_NASAB',
                      groupValue: _relationshipType,
                      title: 'NON-NASAB',
                      onChanged: (v) => setState(() => _relationshipType = v!),
                    ),
                  ),
                ],
              ),
              if (_relationshipType == 'NON_NASAB') ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Hubungan Non-Nasab wajib menyertakan dokumen pendukung (Surat Wasiat/Hibah).',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _isUploadingDoc ? null : _pickSupportingDocument,
                  icon: _isUploadingDoc
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          _supportingDocumentUrl != null
                              ? Icons.check_circle
                              : Icons.upload_file,
                          size: 18,
                        ),
                  label: Text(
                    _supportingDocumentUrl != null
                        ? 'Dokumen Terunggah'
                        : 'Unggah Dokumen Pendukung',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _supportingDocumentUrl != null
                        ? AppColors.success
                        : null,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: generateState.isLoading ? null : _generate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: generateState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Buat Link Undangan',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 28),
              const WtSectionTitle('Undangan Aktif'),
              const SizedBox(height: 12),
              invitationsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text(
                  e.toString(),
                  style: const TextStyle(color: AppColors.danger),
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return const Text(
                      'Belum ada undangan.',
                      style: TextStyle(color: AppColors.gray500),
                    );
                  }
                  return Column(
                    children: items
                        .whereType<Map<String, dynamic>>()
                        .map((inv) => _InvitationCard(invitation: inv))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InvitationCard extends StatelessWidget {
  final Map<String, dynamic> invitation;
  const _InvitationCard({required this.invitation});

  @override
  Widget build(BuildContext context) {
    final code = invitation['code']?.toString() ?? '-';
    final link = invitation['invitationLink']?.toString() ?? '';
    final status = invitation['status']?.toString() ?? 'PENDING';
    final isUsed = status == 'USED';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: WtSurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    code,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                WtStatusBadge(
                  label: isUsed ? 'Dipakai' : 'Menunggu',
                  color: isUsed ? AppColors.success : AppColors.amber,
                  dot: true,
                ),
              ],
            ),
            if (!isUsed && link.isNotEmpty) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      copyToClipboard(context, link, 'Link undangan'),
                  icon: const Icon(Icons.link, size: 16),
                  label: const Text(
                    'Salin Link Undangan',
                    style: TextStyle(fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
