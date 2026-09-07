import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/core/network/storage_upload_service.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/utils/phone_number_utils.dart';
import 'package:wt_mobile/core/widgets/wt_widgets.dart';
import 'package:wt_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:wt_mobile/features/users/presentation/providers/user_provider.dart';

/// Edit profil (nama, kata sandi) & foto profil — PATCH /users/:id dan
/// PATCH /users/me/avatar. Dipakai oleh ketiga role (Pewaris/Ahli Waris/Notaris).
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _storageUploadService = StorageUploadService();

  bool _changePassword = false;
  bool _isUploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).value;
    _nameCtrl.text = user?.name ?? '';
    _emailCtrl.text = user?.email ?? '';
    _phoneCtrl.text = user?.phone ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final userId = ref.read(authProvider).value?.id;
    if (userId == null) return;

    setState(() => _isUploadingAvatar = true);
    try {
      final fileUrl = await _storageUploadService.pickAndUpload(
        UploadPurpose.profilePhoto,
      );
      if (fileUrl == null) return; // dibatalkan pengguna

      await ref.read(updateAvatarProvider.notifier).update(fileUrl);
      if (!mounted) return;

      final state = ref.read(updateAvatarProvider);
      if (state.hasError) {
        WtSnackbar.error(context, state.error.toString());
      } else {
        WtSnackbar.success(context, 'Foto profil berhasil diperbarui.');
      }
    } catch (e) {
      if (mounted) WtSnackbar.error(context, e.toString());
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;
    final userId = ref.read(authProvider).value?.id;
    if (userId == null) return;

    await ref
        .read(updateProfileProvider.notifier)
        .update(
          userId: userId,
          fullName: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          phone: PhoneNumberUtils.normalize(_phoneCtrl.text.trim()) ??
              _phoneCtrl.text.trim(),
          currentPassword: _changePassword
              ? _currentPasswordCtrl.text
              : null,
          newPassword: _changePassword ? _newPasswordCtrl.text : null,
        );
    if (!mounted) return;

    final state = ref.read(updateProfileProvider);
    if (state.hasError) {
      WtSnackbar.error(context, state.error.toString());
      return;
    }
    WtSnackbar.success(context, 'Profil berhasil diperbarui.');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;
    final isSaving = ref.watch(updateProfileProvider).isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? AppColors.gray800
                              : AppColors.gray100,
                          border: Border.all(
                            color: isDark
                                ? AppColors.gray700
                                : AppColors.gray200,
                            width: 3,
                          ),
                          image: user?.avatarUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(user!.avatarUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: user?.avatarUrl == null
                            ? Text(
                                (user != null && user.name.trim().isNotEmpty)
                                    ? user.name.trim()[0].toUpperCase()
                                    : 'P',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? Colors.white70
                                      : AppColors.gray600,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: InkWell(
                          onTap: _isUploadingAvatar ? null : _pickAvatar,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                            alignment: Alignment.center,
                            child: _isUploadingAvatar
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.camera_alt,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                WtFormField(
                  label: 'Nama Lengkap',
                  controller: _nameCtrl,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Nama tidak boleh kosong'
                      : null,
                ),
                const SizedBox(height: 16),
                WtFormField(
                  label: 'Email',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email tidak boleh kosong';
                    if (!RegExp(r'^.+@.+\..+$').hasMatch(v)) return 'Format email tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                WtFormField(
                  label: 'No. HP',
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  hintText: '081234567890',
                  validator: PhoneNumberUtils.validator,
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: () =>
                      setState(() => _changePassword = !_changePassword),
                  child: Row(
                    children: [
                      Icon(
                        _changePassword
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_right,
                        color: AppColors.gray500,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Ganti Kata Sandi',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_changePassword) ...[
                  const SizedBox(height: 12),
                  WtFormField(
                    label: 'Kata Sandi Saat Ini',
                    controller: _currentPasswordCtrl,
                    isPassword: true,
                    validator: (v) => _changePassword && (v == null || v.isEmpty)
                        ? 'Wajib diisi untuk mengganti kata sandi'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  WtFormField(
                    label: 'Kata Sandi Baru',
                    controller: _newPasswordCtrl,
                    isPassword: true,
                    validator: (v) {
                      if (!_changePassword) return null;
                      if (v == null || v.isEmpty) return 'Wajib diisi';
                      if (v.length < 8) return 'Minimal 8 karakter';
                      final hasUpper = v.contains(RegExp('[A-Z]'));
                      final hasLower = v.contains(RegExp('[a-z]'));
                      final hasDigit = v.contains(RegExp('[0-9]'));
                      if (!hasUpper || !hasLower || !hasDigit) {
                        return 'Harus mengandung huruf besar, kecil, dan angka';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  WtFormField(
                    label: 'Konfirmasi Kata Sandi Baru',
                    controller: _confirmPasswordCtrl,
                    isPassword: true,
                    validator: (v) => _changePassword &&
                            v != _newPasswordCtrl.text
                        ? 'Kata sandi tidak sama'
                        : null,
                  ),
                ],
                const SizedBox(height: 28),
                WtPrimaryButton(
                  label: 'Simpan Perubahan',
                  isLoading: isSaving,
                  onPressed: isSaving ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
