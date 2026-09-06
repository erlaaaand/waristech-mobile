import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';
import 'package:wt_mobile/core/widgets/wt_decorative.dart';

/// Struktur baku untuk SEMUA layar autentikasi (login, registrasi, lupa/reset
/// password, verifikasi email): [WtAuthBackdrop] di belakang + konten
/// dibatasi lebar maksimum dan di-tengah-kan (responsive — tidak melar
/// edge-to-edge di tablet/layar lebar) + animasi masuk fade+slide-up sekali
/// saat layar dibuka.
///
/// Jika [showBackButton] true, dipasang `AppBar` transparan tanpa judul
/// (judul kontekstual ada di body lewat [WtAuthHeader]) khusus untuk
/// affordance tombol kembali — dipakai layar sub-alur (registrasi, lupa/reset
/// password, verifikasi email), TIDAK dipakai layar login karena login
/// adalah layar identitas utama, bukan sub-alur.
class WtAuthScaffold extends StatelessWidget {
  static const double _maxContentWidth = 440;

  final Widget child;
  final bool showBackButton;

  const WtAuthScaffold({
    super.key,
    required this.child,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: showBackButton,
      appBar: showBackButton
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    // Fallback aman jika rute dibuka dengan context.go (stack kosong)
                    context.go('/login');
                  }
                },
              ),
            )
          : null,
      body: Stack(
        children: [
          const WtAuthBackdrop(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _maxContentWidth),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    showBackButton ? kToolbarHeight : 24,
                    24,
                    24,
                  ),
                  child: _FadeSlideIn(child: child),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animasi masuk fade+slide-up sederhana, jalan sekali saat widget dipasang
/// — dipakai [WtAuthScaffold] supaya konten layar auth tidak muncul statis.
class _FadeSlideIn extends StatefulWidget {
  final Widget child;
  const _FadeSlideIn({required this.child});

  @override
  State<_FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<_FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 380),
      vsync: this,
    );
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _fade = curved;
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(curved);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

/// Header kontekstual layar auth sub-alur: judul besar rata-kiri + subjudul.
/// Menggantikan judul `AppBar` (dihapus di [WtAuthScaffold] agar tidak
/// dobel) dan blok Icon/Text/Text yang sebelumnya ditulis ulang di tiap
/// layar (registrasi, lupa/reset password, verifikasi email). Murni
/// tipografi — tanpa ikon dekoratif, mengikuti gaya referensi.
class WtAuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const WtAuthHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            height: 1.15,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.4,
            color: (isDark ? Colors.white : AppColors.navy).withValues(
              alpha: 0.6,
            ),
          ),
        ),
      ],
    );
  }
}

/// Field form khusus layar auth — pil solid TANPA border terlihat (hanya
/// fill color), berbeda dari `WtFormField` (dipakai app-wide) yang punya
/// `OutlineInputBorder` alpha-0.1 selalu tampak. Garis tipis hanya muncul
/// saat field fokus, sebagai affordance minimal, bukan stroke permanen.
/// Label pakai `InputDecoration.labelText` bawaan (floating saat
/// fokus/terisi) — field tetap jelas begitu terisi tanpa label terpisah
/// di luar seperti `WtFormField`.
class WtAuthField extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final Widget? prefixIcon;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool isPassword;
  final int? maxLength;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const WtAuthField({
    super.key,
    required this.label,
    this.controller,
    this.hintText,
    this.prefixIcon,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.isPassword = false,
    this.maxLength,
    this.validator,
    this.onChanged,
  });

  @override
  State<WtAuthField> createState() => _WtAuthFieldState();
}

class _WtAuthFieldState extends State<WtAuthField> {
  bool _isRevealed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final obscure = widget.isPassword && !_isRevealed;
    final accent = isDark ? AppColors.primaryLight : AppColors.primary;

    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      textCapitalization: widget.textCapitalization,
      obscureText: obscure,
      maxLength: widget.maxLength,
      validator: widget.validator,
      onChanged: widget.onChanged,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon,
        prefixIconColor: isDark ? Colors.white70 : AppColors.navy.withValues(alpha: 0.6),
        suffixIconColor: isDark ? Colors.white70 : AppColors.navy.withValues(alpha: 0.6),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _isRevealed ? Icons.visibility_off : Icons.visibility,
                ),
                tooltip: _isRevealed
                    ? 'Sembunyikan kata sandi'
                    : 'Tampilkan kata sandi',
                onPressed: () => setState(() => _isRevealed = !_isRevealed),
              )
            : null,
        counterText: '',
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : AppColors.warm,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: isDark 
              ? BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 1)
              : BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: isDark 
              ? BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 1)
              : BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
      ),
    );
  }
}

/// Tombol utama khusus layar auth — kontras dibalik sesuai tema
/// (`isDark ? putih-di-atas-hitam : hitam-di-atas-putih`), memperbaiki bug
/// laten `WtPrimaryButton` (dipakai app-wide) yang selalu hitam di kedua
/// tema sehingga nyaris tak terlihat di latar gelap.
class WtAuthButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const WtAuthButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.primaryLight : AppColors.primary;
    final fg = isDark ? AppColors.primaryDeep : Colors.white;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          disabledBackgroundColor: bg.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: animation, child: child),
          ),
          child: isLoading
              ? SizedBox(
                  key: const ValueKey('loading'),
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: fg, strokeWidth: 3),
                )
              : Text(
                  key: const ValueKey('label'),
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Input OTP tersegmentasi (kotak per digit) — pengganti field OTP tunggal
/// dengan letter-spacing yang sebelumnya dipakai `verify_email_screen.dart`
/// & `reset_password_screen.dart` dengan gaya berbeda-beda. Auto-advance ke
/// kotak berikutnya saat terisi; backspace pada kotak yang sudah kosong
/// (mengosongkan kotak sebelumnya) mundur satu kotak — cukup untuk kasus
/// koreksi paling umum tanpa raw-key-listener yang berisiko konflik fokus.
class WtOtpField extends StatefulWidget {
  final int length;
  final ValueChanged<String> onChanged;

  /// Caption kecil di atas kotak-kotak (mis. "Kode OTP") — opsional karena
  /// beberapa layar sudah menjelaskan lewat [WtAuthHeader] di atasnya.
  final String? label;

  const WtOtpField({
    super.key,
    this.length = 6,
    required this.onChanged,
    this.label,
  });

  @override
  State<WtOtpField> createState() => _WtOtpFieldState();
}

class _WtOtpFieldState extends State<WtOtpField> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (_) => TextEditingController(),
    );
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleChanged(int index, String value) {
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    widget.onChanged(_controllers.map((c) => c.text).join());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.primaryLight : AppColors.primary;

    final boxes = Row(
      children: List.generate(widget.length * 2 - 1, (i) {
        if (i.isOdd) return const SizedBox(width: 8);
        final index = i ~/ 2;
        return Expanded(
          child: SizedBox(
            height: 56,
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(1),
              ],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                counterText: '',
                contentPadding: EdgeInsets.zero,
                filled: true,
                fillColor: isDark ? AppColors.darkSurface : AppColors.warm,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: isDark 
                      ? BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 1)
                      : BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: isDark 
                      ? BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 1)
                      : BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: accent, width: 1.5),
                ),
              ),
              onChanged: (value) => _handleChanged(index, value),
            ),
          ),
        );
      }),
    );

    if (widget.label == null) return boxes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label!.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            color: (isDark ? Colors.white : AppColors.navy).withValues(
              alpha: 0.7,
            ),
          ),
        ),
        const SizedBox(height: 8),
        boxes,
      ],
    );
  }
}
