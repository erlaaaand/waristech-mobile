import 'package:flutter/material.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';

/// Field form baku bergaya prototipe: label kecil uppercase di atas kotak
/// input h-14 rounded-16 ber-latar `warm`/`navy` — dipakai di semua form
/// (undangan, saksi, aset) alih-alih `TextFormField` polos bawaan Material.
class WtFormField extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool obscureText;

  /// Jika true, field menyembunyikan teks DAN menyediakan tombol
  /// lihat/sembunyikan yang state-nya dikelola sendiri di sini — pemanggil
  /// tidak perlu lagi menyimpan `bool _isPasswordVisible` di layarnya.
  final bool isPassword;
  final int maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const WtFormField({
    super.key,
    required this.label,
    this.controller,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.isPassword = false,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.onChanged,
  });

  @override
  State<WtFormField> createState() => _WtFormFieldState();
}

class _WtFormFieldState extends State<WtFormField> {
  bool _isRevealed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool obscure = widget.isPassword ? !_isRevealed : widget.obscureText;

    final Widget? suffixIcon = widget.isPassword
        ? IconButton(
            icon: Icon(_isRevealed ? Icons.visibility_off : Icons.visibility),
            tooltip: _isRevealed
                ? 'Sembunyikan kata sandi'
                : 'Tampilkan kata sandi',
            onPressed: () => setState(() => _isRevealed = !_isRevealed),
          )
        : widget.suffixIcon;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            color: isDark
                ? Colors.white.withValues(alpha: 0.4)
                : AppColors.navy.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          textCapitalization: widget.textCapitalization,
          obscureText: obscure,
          maxLines: obscure ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          validator: widget.validator,
          onChanged: widget.onChanged,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: suffixIcon,
            counterText: '',
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            filled: true,
            fillColor: isDark
                ? AppColors.navy.withValues(alpha: 0.2)
                : AppColors.warm,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: (isDark ? Colors.white : AppColors.navy).withValues(
                  alpha: 0.1,
                ),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: (isDark ? Colors.white : AppColors.navy).withValues(
                  alpha: 0.1,
                ),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

/// Baris pilihan singkat (chip) di bawah [WtFormField] — dipakai untuk
/// menyarankan nilai umum (mis. hubungan keluarga) tanpa mengganti field
/// menjadi dropdown tertutup, karena backend menerima teks bebas.
class WtSuggestionChips extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelected;

  const WtSuggestionChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isActive = opt == selected;
        return GestureDetector(
          onTap: () => onSelected(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary
                  : (isDark
                        ? AppColors.navy.withValues(alpha: 0.2)
                        : AppColors.warm),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              opt,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? Colors.white
                    : (isDark ? Colors.white : AppColors.navy),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Field kata sandi dengan tombol lihat/sembunyikan yang mengelola state-nya
/// SENDIRI.
///
/// Sebelumnya tiap layar (login, registrasi Pewaris, registrasi Ahli Waris)
/// menyimpan `bool _isPasswordVisible` di state layarnya masing-masing —
/// duplikasi yang juga membuat seluruh layar rebuild hanya karena ikon mata
/// ditekan. Di sini rebuild terbatas pada field ini saja.
class WtPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final String? Function(String?)? validator;

  const WtPasswordField({
    super.key,
    required this.controller,
    this.labelText = 'Kata Sandi',
    this.hintText,
    this.validator,
  });

  @override
  State<WtPasswordField> createState() => _WtPasswordFieldState();
}

class _WtPasswordFieldState extends State<WtPasswordField> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: widget.controller,
      obscureText: !_isVisible,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_isVisible ? Icons.visibility_off : Icons.visibility),
          tooltip: _isVisible
              ? 'Sembunyikan kata sandi'
              : 'Tampilkan kata sandi',
          onPressed: () => setState(() => _isVisible = !_isVisible),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : Colors.white,
      ),
      validator: widget.validator,
    );
  }
}

/// Checkbox persetujuan pemrosesan data pribadi (UU PDP).
///
/// Sebelumnya method `_consentCheckbox(bool isDark)` yang identik disalin di
/// layar registrasi Pewaris DAN Ahli Waris. Dijadikan satu komponen agnostik
/// di sini: pemanggil cukup mengirim nilai, teks, dan callback.
class WtConsentCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String text;

  const WtConsentCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: (isDark ? Colors.white : AppColors.navy).withValues(
            alpha: 0.04,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: value,
              onChanged: (v) => onChanged(v ?? false),
              activeColor: AppColors.primary,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: (isDark ? Colors.white : AppColors.navy).withValues(
                      alpha: 0.7,
                    ),
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

/// Item untuk [WtDropdownField]
class WtDropdownItem<T> {
  final T value;
  final String label;

  const WtDropdownItem({required this.value, required this.label});
}

/// Dropdown field kustom yang persis sama dengan [WtFormField] namun 
/// memunculkan bottom sheet modern dan premium alih-alih native menu.
class WtDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<WtDropdownItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;
  final String hintText;

  const WtDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.hintText = 'Pilih salah satu...',
  });

  void _showBottomSheet(BuildContext context, bool isDark) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (ctx, i) {
                    final item = items[i];
                    final isSelected = item.value == value;
                    return InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        onChanged(item.value);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : Colors.transparent,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? AppColors.primary
                                      : (isDark
                                          ? Colors.white
                                          : AppColors.navy),
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedItem = items.where((e) => e.value == value).firstOrNull;
    final displayLabel = selectedItem?.label ?? hintText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            color: isDark
                ? Colors.white.withValues(alpha: 0.4)
                : AppColors.navy.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        FormField<T>(
          initialValue: value,
          validator: validator,
          builder: (FormFieldState<T> state) {
            final hasError = state.hasError;
            return InkWell(
              onTap: () => _showBottomSheet(context, isDark),
              borderRadius: BorderRadius.circular(16),
              child: InputDecorator(
                decoration: InputDecoration(
                  errorText: state.errorText,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.navy.withValues(alpha: 0.2)
                      : AppColors.warm,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: (isDark ? Colors.white : AppColors.navy).withValues(
                        alpha: 0.1,
                      ),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: (isDark ? Colors.white : AppColors.navy).withValues(
                        alpha: 0.1,
                      ),
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        displayLabel,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: selectedItem == null
                              ? (isDark ? Colors.white38 : Colors.black38)
                              : (isDark ? Colors.white : AppColors.navy),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: isDark ? Colors.white70 : AppColors.gray500,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
