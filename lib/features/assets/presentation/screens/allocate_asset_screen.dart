import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/assets/domain/entities/asset_entity.dart';
import 'package:wt_mobile/features/assets/presentation/providers/asset_provider.dart';
import 'package:wt_mobile/features/assets/presentation/screens/rotate_key_shares_screen.dart';
import 'package:wt_mobile/features/inheritance/presentation/providers/inheritance_provider.dart';

/// (Pewaris) Alokasikan persentase aset ke Ahli Waris — POST /assets/:id/allocate.
/// Backend HANYA mengizinkan alokasi selama status aset masih
/// PENDING_VERIFICATION — setelah diverifikasi Notaris, alokasi terkunci.
class AllocateAssetScreen extends ConsumerStatefulWidget {
  final AssetEntity asset;
  const AllocateAssetScreen({super.key, required this.asset});

  @override
  ConsumerState<AllocateAssetScreen> createState() =>
      _AllocateAssetScreenState();
}

class _AllocateAssetScreenState extends ConsumerState<AllocateAssetScreen> {
  String? _selectedAhliWarisId;
  final _percentageCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  bool _isExecutor = false;

  @override
  void dispose() {
    _percentageCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  double get _allocatedSoFar =>
      widget.asset.allocations.fold(0.0, (sum, a) => sum + a.percentage);

  Future<void> _submit() async {
    final ahliWarisId = _selectedAhliWarisId;
    final percentage = double.tryParse(_percentageCtrl.text.trim());
    if (ahliWarisId == null) {
      _showSnack('Pilih Ahli Waris terlebih dahulu.', isError: true);
      return;
    }
    if (percentage == null || percentage <= 0 || percentage > 100) {
      _showSnack('Persentase harus antara 1-100.', isError: true);
      return;
    }

    await ref
        .read(allocateAssetProvider(widget.asset.id).notifier)
        .allocate(
          assetId: widget.asset.id,
          ahliWarisId: ahliWarisId,
          percentage: percentage,
          isExecutor: _isExecutor,
          reason: _reasonCtrl.text.trim().isEmpty
              ? null
              : _reasonCtrl.text.trim(),
        );
    if (!mounted) return;
    final state = ref.read(allocateAssetProvider(widget.asset.id));
    if (state.hasError) {
      _showSnack(state.error.toString(), isError: true);
      return;
    }
    _showSnack('Alokasi berhasil disimpan.');
    _percentageCtrl.clear();
    _reasonCtrl.clear();
    setState(() {
      _selectedAhliWarisId = null;
      _isExecutor = false;
    });
  }

  void _showSnack(String message, {bool isError = false}) {
    if (isError) {
      WtSnackbar.error(context, message);
    } else {
      WtSnackbar.success(context, message, backgroundColor: AppColors.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(familyMembersProvider);
    final isLoading = ref
        .watch(allocateAssetProvider(widget.asset.id))
        .isLoading;
    final isLocked = widget.asset.status != AssetStatus.pendingVerification;

    return Scaffold(
      appBar: AppBar(
        title: Text('Alokasi — ${widget.asset.assetName}'),
        actions: [
          if (widget.asset.isVaultCustody)
            IconButton(
              icon: const Icon(Icons.autorenew),
              tooltip: 'Rotasi Kunci',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => RotateKeySharesScreen(
                    assetId: widget.asset.id,
                    assetName: widget.asset.assetName,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AllocationSummary(
                asset: widget.asset,
                allocatedSoFar: _allocatedSoFar,
                members: membersAsync.valueOrNull ?? const [],
              ),
              const SizedBox(height: 20),
              if (isLocked) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'Alokasi terkunci — status aset sudah "${widget.asset.status.displayLabel}". '
                    'Alokasi hanya dapat diubah sebelum Notaris melakukan verifikasi.',
                    style: const TextStyle(fontSize: 12.5, height: 1.4),
                  ),
                ),
              ] else ...[
                const Text(
                  'Tambah Alokasi',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
                const SizedBox(height: 12),
                membersAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text(
                    e.toString(),
                    style: const TextStyle(color: AppColors.danger),
                  ),
                  data: (members) => _MemberDropdown(
                    members: members,
                    selectedId: _selectedAhliWarisId,
                    onChanged: (v) => setState(() => _selectedAhliWarisId = v),
                  ),
                ),
                const SizedBox(height: 12),
                WtFormField(
                  label: 'Persentase (%)',
                  controller: _percentageCtrl,
                  hintText:
                      'Sisa kapasitas: ${(100 - _allocatedSoFar).toStringAsFixed(1)}%',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 12),
                WtToggleCard(
                  icon: Icons.key,
                  color: AppColors.primary,
                  title: 'Eksekutor Utama',
                  description: 'Hanya Eksekutor yang memegang kunci enkripsi aset (maks 1 orang per aset).',
                  value: _isExecutor,
                  onChanged: (v) => setState(() => _isExecutor = v),
                ),
                const SizedBox(height: 12),
                WtFormField(
                  label: 'Alasan (bila menyimpang dari skema hukum waris)',
                  controller: _reasonCtrl,
                  hintText: 'Wajib diisi HANYA bila persentase menyimpang dari skema pilihan Anda',
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text('Simpan Alokasi'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AllocationSummary extends ConsumerWidget {
  final AssetEntity asset;
  final double allocatedSoFar;
  final List<dynamic> members;
  const _AllocationSummary({
    required this.asset,
    required this.allocatedSoFar,
    this.members = const [],
  });

  /// Nama Ahli Waris dari daftar anggota keluarga Pewaris — allocation entity
  /// hanya menyimpan ahliWarisId (UUID), jadi nama harus dicocokkan lewat ID.
  String _nameFor(String ahliWarisId) {
    final match = members.whereType<Map<String, dynamic>>().where(
      (m) => m['ahliWarisId']?.toString() == ahliWarisId,
    );
    if (match.isEmpty) return 'Ahli Waris';
    
    final m = match.first;
    final ahliWarisObj = m['ahliWaris'] as Map<String, dynamic>?;
    final accountName = ahliWarisObj?['fullName']?.toString();
    
    if (accountName != null && accountName.isNotEmpty) {
      return accountName;
    }
    
    final name = m['ahliWarisName']?.toString().trim();
    if (name != null && name.isNotEmpty) return name;
    
    return m['relationshipDescription']?.toString().trim() ?? 'Ahli Waris';
  }

  Future<void> _showSchemeEditor(BuildContext context, WidgetRef ref) async {
    var selected = asset.inheritanceScheme;
    final chosen = await showModalBottomSheet<InheritanceScheme?>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ubah Skema Waris',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: InheritanceScheme.values.map((scheme) {
                  final isSelected = selected == scheme;
                  return ChoiceChip(
                    label: Text(scheme.displayName),
                    selected: isSelected,
                    onSelected: (_) => setSheetState(
                      () => selected = isSelected ? null : scheme,
                    ),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, selected),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (chosen == null || chosen == asset.inheritanceScheme) return;
    if (!context.mounted) return;
    await ref
        .read(updateAssetSchemeProvider(asset.id).notifier)
        .update(assetId: asset.id, inheritanceScheme: chosen.backendValue);
    if (!context.mounted) return;
    final state = ref.read(updateAssetSchemeProvider(asset.id));
    if (state.hasError) {
      WtSnackbar.error(context, state.error.toString());
    } else {
      WtSnackbar.success(context, 'Skema waris diperbarui.');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WtSurfaceCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              WtAnimatedProgressRing(
                value: allocatedSoFar / 100,
                size: 44,
                strokeWidth: 4.5,
                color: allocatedSoFar >= 100
                    ? AppColors.success
                    : AppColors.primary,
                child: Text(
                  '${allocatedSoFar.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    color: allocatedSoFar >= 100
                        ? AppColors.success
                        : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Total teralokasi: ${allocatedSoFar.toStringAsFixed(1)}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.balance_outlined,
                      size: 15,
                      color: AppColors.gray500,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      asset.inheritanceScheme != null
                          ? 'Skema ${asset.inheritanceScheme!.displayName}'
                          : 'Skema belum ditentukan',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),
              if (!asset.isSchemeLocked)
                TextButton(
                  onPressed: () => _showSchemeEditor(context, ref),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                  ),
                  child: const Text(
                    'Ubah',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (asset.allocations.isEmpty)
            const Text(
              'Belum ada alokasi.',
              style: TextStyle(color: AppColors.gray500, fontSize: 13),
            )
          else
            ...asset.allocations.map(
              (a) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _nameFor(a.ahliWarisId),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12.5),
                      ),
                    ),
                    if (a.isExecutor)
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Text(
                          'Eksekutor',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    Text(
                      '${a.percentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MemberDropdown extends StatelessWidget {
  final List<dynamic> members;
  final String? selectedId;
  final ValueChanged<String?> onChanged;
  const _MemberDropdown({
    required this.members,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = members.whereType<Map<String, dynamic>>().toList();
    if (items.isEmpty) {
      return const Text(
        'Belum ada anggota keluarga terdaftar. Undang Ahli Waris terlebih dahulu.',
        style: TextStyle(color: AppColors.gray500, fontSize: 13),
      );
    }
    
    final dropdownItems = items.map((m) {
      final id = m['ahliWarisId']?.toString() ?? '';
      
      // Jika sudah dikonfirmasi, gunakan nama asli dari akun ahli waris
      final ahliWarisObj = m['ahliWaris'] as Map<String, dynamic>?;
      final accountName = ahliWarisObj?['fullName']?.toString();
      
      String name;
      if (accountName != null && accountName.isNotEmpty) {
        name = accountName;
      } else if (m['ahliWarisName']?.toString().trim().isNotEmpty == true) {
        name = m['ahliWarisName'].toString().trim();
      } else {
        name = m['relationshipDescription']?.toString().trim() ?? 'Ahli Waris';
      }
      
      final desc = m['relationshipDescription']?.toString() ?? '-';
      final label = (name == desc) ? name : '$name ($desc)';
      
      return WtDropdownItem(
        value: id,
        label: label,
        avatarUrl: ahliWarisObj?['avatarUrl']?.toString() ?? '',
      );
    }).toList();

    return WtDropdownField<String>(
      label: 'Ahli Waris',
      value: selectedId,
      items: dropdownItems,
      onChanged: onChanged,
    );
  }
}
