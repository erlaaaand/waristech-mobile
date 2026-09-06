import 'package:flutter/material.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';

/// Bungkus [child] yang bisa ditekan dengan efek *scale-down* + ripple,
/// meniru `active:scale-95` dari prototipe web. Gunakan untuk kartu/tombol
/// yang seharusnya terasa "hidup" saat disentuh (mis. `WtStatCard`, `WtInfoCard`).
class BouncingWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final BorderRadius borderRadius;

  const BouncingWrapper({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.95,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
  });

  @override
  State<BouncingWrapper> createState() => _BouncingWrapperState();
}

class _BouncingWrapperState extends State<BouncingWrapper> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? widget.scale : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        borderRadius: widget.borderRadius,
        child: InkWell(
          borderRadius: widget.borderRadius,
          onTap: widget.onTap,
          onHighlightChanged: (v) => setState(() => _pressed = v),
          child: widget.child,
        ),
      ),
    );
  }
}

/// [IndexedStack] yang fade-in setiap kali `index` berganti, meniru transisi
/// *fade-through* SPA modern — tanpa `instant cut` seperti IndexedStack biasa.
///
/// Semua children TETAP dipertahankan di widget tree (tidak seperti
/// [AnimatedSwitcher] yang membongkar child lama), sehingga state tiap tab
/// (posisi scroll, provider `autoDispose` yang sedang loading, dsb.) tidak
/// hilang saat berpindah tab lalu kembali lagi.
class FadeIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;
  final Duration duration;

  const FadeIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.duration = const Duration(milliseconds: 220),
  });

  @override
  State<FadeIndexedStack> createState() => _FadeIndexedStackState();
}

class _FadeIndexedStackState extends State<FadeIndexedStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: 1.0,
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void didUpdateWidget(FadeIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index != oldWidget.index) {
      _controller.forward(from: 0);
    }
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
      child: IndexedStack(index: widget.index, children: widget.children),
    );
  }
}

/// Ring radio custom ala prototipe (`.radio-ring`) — lingkaran 22px dengan
/// border abu-abu, berubah warna rose (#F43F5E) dan titik tengah muncul
/// gradual (~150ms) saat terpilih. Pakai langsung sebagai indikator visual,
/// atau lewat [WtRadioListTile] untuk baris pilihan lengkap dengan label.
class WtAnimatedRadio<T> extends StatelessWidget {
  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;

  const WtAnimatedRadio({
    super.key,
    required this.value,
    required this.groupValue,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return GestureDetector(
      onTap: onChanged == null ? null : () => onChanged!(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppColors.rose : AppColors.divider,
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: selected ? 1.0 : 0.0,
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.rose,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

/// Baris pilihan radio lengkap (ring + label) memakai [WtAnimatedRadio] —
/// pengganti [RadioListTile] bawaan agar transisinya konsisten dengan
/// prototipe web (`.relation-item`).
class WtRadioListTile<T> extends StatelessWidget {
  final T value;
  final T? groupValue;
  final String title;
  final ValueChanged<T?> onChanged;
  final EdgeInsetsGeometry padding;

  const WtRadioListTile({
    super.key,
    required this.value,
    required this.groupValue,
    required this.title,
    required this.onChanged,
    this.padding = const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            WtAnimatedRadio<T>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
            ),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

/// Ring progres melingkar yang "dash-in" dari 0 menuju [value] setiap kali
/// nilainya berubah — meniru animasi `stroke-dashoffset` pada donut chart
/// di prototipe web, tanpa perlu CustomPainter.
class WtAnimatedProgressRing extends StatelessWidget {
  final double value;
  final double size;
  final double strokeWidth;
  final Color color;
  final Color? backgroundColor;
  final Widget? child;

  const WtAnimatedProgressRing({
    super.key,
    required this.value,
    required this.color,
    this.size = 56,
    this.strokeWidth = 6,
    this.backgroundColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: value.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: 1,
                strokeWidth: strokeWidth,
                valueColor: AlwaysStoppedAnimation<Color>(
                  backgroundColor ?? color.withValues(alpha: 0.12),
                ),
              ),
              CircularProgressIndicator(
                value: animatedValue,
                strokeWidth: strokeWidth,
                strokeCap: StrokeCap.round,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              ?child,
            ],
          ),
        );
      },
    );
  }
}
