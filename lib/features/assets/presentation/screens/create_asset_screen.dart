import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/assets/domain/entities/asset_entity.dart';
import 'package:wt_mobile/features/assets/presentation/providers/asset_provider.dart';
import 'package:wt_mobile/features/assets/presentation/screens/asset_guidance_screen.dart';

/// Form pembuatan aset baru — POST /assets.
/// custodyType VAULT: kredensial dititipkan & dipecah Shamir (butuh field
/// secret). custodyType GUIDANCE: kredensial TIDAK dititipkan, sistem hanya
/// memberi panduan proses resmi (dianjurkan untuk rekening bank/asuransi).
class CreateAssetScreen extends ConsumerStatefulWidget {
  const CreateAssetScreen({super.key});

  @override
  ConsumerState<CreateAssetScreen> createState() => _CreateAssetScreenState();
}

class _CreateAssetScreenState extends ConsumerState<CreateAssetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _assetNameCtrl = TextEditingController();
  final _platformCtrl = TextEditingController();
  final _accountIdentifierCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  AssetType _type = AssetType.crypto;
  AssetCustodyType _custodyType = AssetCustodyType.vault;
  String? _selectedNotarisId;

  @override
  void dispose() {
    _assetNameCtrl.dispose();
    _platformCtrl.dispose();
    _accountIdentifierCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _pinCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  /// Rekening bank & asuransi jiwa disarankan GUIDANCE — menitipkan PIN/
  /// password lembaga resmi umumnya melanggar syarat & ketentuan mereka.
  bool get _guidanceRecommended =>
      _type == AssetType.rekeningBank || _type == AssetType.asuransiJiwa;

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;
    if (_selectedNotarisId == null) {
      WtSnackbar.error(context, 'Wajib memilih Notaris pemeriksa');
      return;
    }

    final notifier = ref.read(createAssetProvider.notifier);
    await notifier.create(
      type: _type.backendValue,
      assetName: _assetNameCtrl.text.trim(),
      platform: _platformCtrl.text.trim(),
      accountIdentifier: _accountIdentifierCtrl.text.trim(),
      assignedNotarisId: _selectedNotarisId!,
      custodyType: _custodyType == AssetCustodyType.vault
          ? 'VAULT'
          : 'GUIDANCE',
      secret: _custodyType == AssetCustodyType.vault
          ? {
              if (_usernameCtrl.text.trim().isNotEmpty)
                'username': _usernameCtrl.text.trim(),
              if (_passwordCtrl.text.isNotEmpty) 'password': _passwordCtrl.text,
              if (_pinCtrl.text.trim().isNotEmpty) 'pin': _pinCtrl.text.trim(),
              if (_notesCtrl.text.trim().isNotEmpty)
                'notes': _notesCtrl.text.trim(),
            }
          : null,
    );

    if (!mounted) return;
    final state = ref.read(createAssetProvider);

    if (state.hasError) {
      WtSnackbar.error(context, state.error.toString());
      return;
    }

    final result = state.value;
    if (result == null) return;

    if (result.isVault) {
      context.pushReplacementNamed('share-reveal', extra: result);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => AssetGuidanceScreen(
            assetName: result.asset.assetName,
            preloaded: result.guidance,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(createAssetProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Aset Digital')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AssetTypeDropdown(
                  value: _type,
                  onChanged: (v) => setState(() {
                    _type = v;
                    // Sarankan GUIDANCE otomatis untuk lembaga resmi,
                    // tetap bisa diubah manual.
                    if (_guidanceRecommended) {
                      _custodyType = AssetCustodyType.guidance;
                    }
                  }),
                ),
                const SizedBox(height: 16),
                WtFormField(
                  label: 'Nama Aset',
                  controller: _assetNameCtrl,
                  hintText: 'mis. Tabungan Pensiun BCA',
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 16),
                WtFormField(
                  label: 'Platform',
                  controller: _platformCtrl,
                  hintText: 'mis. BCA, Binance',
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 16),
                WtFormField(
                  label: 'Identitas Akun',
                  controller: _accountIdentifierCtrl,
                  hintText: 'Username / email / no. rekening',
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 16),
                _NotarisSelector(
                  value: _selectedNotarisId,
                  onChanged: (val) => setState(() => _selectedNotarisId = val),
                ),
                const SizedBox(height: 24),
                _CustodySelector(
                  value: _custodyType,
                  onChanged: (v) => setState(() => _custodyType = v),
                ),
                if (_custodyType == AssetCustodyType.vault) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Kredensial (akan dipecah & dienkripsi)',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  WtFormField(
                    label: 'Username (opsional)',
                    controller: _usernameCtrl,
                  ),
                  const SizedBox(height: 12),
                  WtFormField(
                    label: 'Password',
                    controller: _passwordCtrl,
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
                  WtFormField(label: 'PIN (opsional)', controller: _pinCtrl),
                  const SizedBox(height: 12),
                  WtFormField(
                    label: 'Catatan (opsional)',
                    controller: _notesCtrl,
                    maxLines: 3,
                  ),
                ],
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text(
                            'Simpan Aset',
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

  String? _requiredValidator(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null;
}

// ---------------------------------------------------------------------------
// Sub-widget form pembuatan aset
// ---------------------------------------------------------------------------

/// Pemilih jenis aset (12 nilai enum `AssetType` dari backend).
class _AssetTypeDropdown extends StatelessWidget {
  final AssetType value;
  final ValueChanged<AssetType> onChanged;

  const _AssetTypeDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return WtDropdownField<AssetType>(
      label: 'Jenis Aset',
      value: value,
      items: AssetType.values
          .map(
            (t) => WtDropdownItem<AssetType>(
              value: t,
              label: t.displayName,
            ),
          )
          .toList(),
      onChanged: (v) {
        if (v == null) return;
        onChanged(v);
      },
    );
  }
}

/// Dua pilihan cara penyimpanan kredensial: VAULT vs GUIDANCE.
class _CustodySelector extends StatelessWidget {
  final AssetCustodyType value;
  final ValueChanged<AssetCustodyType> onChanged;

  const _CustodySelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cara Penyimpanan Kredensial',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        _CustodyOption(
          type: AssetCustodyType.vault,
          groupValue: value,
          title: 'Titipkan (VAULT)',
          desc: 'Kredensial dipecah 3 bagian (Shamir 2-dari-3). Cocok untuk aset self-custody seperti kripto.',
          icon: Icons.enhanced_encryption_outlined,
          onSelected: onChanged,
        ),
        const SizedBox(height: 10),
        _CustodyOption(
          type: AssetCustodyType.guidance,
          groupValue: value,
          title: 'Panduan Saja (GUIDANCE)',
          desc: 'Kredensial TIDAK dititipkan. Sistem memberi panduan proses resmi. Disarankan untuk bank/asuransi.',
          icon: Icons.menu_book_outlined,
          onSelected: onChanged,
        ),
      ],
    );
  }
}

/// Satu baris pilihan kustodi (kartu + radio).
class _CustodyOption extends StatelessWidget {
  final AssetCustodyType type;
  final AssetCustodyType groupValue;
  final String title;
  final String desc;
  final IconData icon;
  final ValueChanged<AssetCustodyType> onSelected;

  const _CustodyOption({
    required this.type,
    required this.groupValue,
    required this.title,
    required this.desc,
    required this.icon,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final selected = groupValue == type;
    return InkWell(
      onTap: () => onSelected(type),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.primaryDeep.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.primaryDeep.withValues(alpha: 0.08),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: selected ? AppColors.primary : AppColors.gray500),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: selected ? AppColors.primary : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(desc, style: const TextStyle(fontSize: 12, height: 1.3)),
                ],
              ),
            ),
            WtAnimatedRadio<AssetCustodyType>(
              value: type,
              groupValue: groupValue,
              onChanged: (v) {
                if (v != null) onSelected(v);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget dropdown untuk memilih Notaris dari provider `notariesProvider`
class _NotarisSelector extends ConsumerWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const _NotarisSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncNotaries = ref.watch(notariesProvider);

    return asyncNotaries.when(
      data: (notaries) {
        return WtDropdownField<String>(
          label: 'Notaris Pemeriksa',
          value: value,
          items: notaries.map((n) {
            return WtDropdownItem<String>(
              value: n['id'] as String,
              label: n['fullName'] as String,
            );
          }).toList(),
          onChanged: onChanged,
          validator: (v) => v == null ? 'Wajib memilih Notaris' : null,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Text(
        'Gagal memuat daftar notaris: $e',
        style: const TextStyle(color: Colors.red),
      ),
    );
  }
}
