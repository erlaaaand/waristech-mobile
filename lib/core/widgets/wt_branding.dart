import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Logo WarisTech dari SVG asset.
class WtLogo extends StatelessWidget {
  final double size;
  const WtLogo({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset('assets/logo.svg', width: size, height: size);
  }
}

/// Logo WarisTech dengan teks judul di sebelahnya.
class WtLogoWithText extends StatelessWidget {
  final String title;
  const WtLogoWithText({super.key, this.title = 'WarisTech'});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const WtLogo(size: 24),
        const SizedBox(width: 8),
        // Flexible+ellipsis — AppBar memberi title lebar terbatas (dikurangi
        // leading/actions); tanpa ini judul bisa RenderFlex overflow saat
        // window menyempit drastis (mis. mode jendela mengambang Android).
        Flexible(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        ),
      ],
    );
  }
}
