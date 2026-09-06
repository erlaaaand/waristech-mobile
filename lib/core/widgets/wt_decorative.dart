import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wt_mobile/core/theme/app_colors.dart';

/// Lingkaran cahaya blur — setara CSS `blur-3xl` pada prototipe.
///
/// [ImageFiltered] mem-blur widget-nya SENDIRI, berbeda dari [BackdropFilter]
/// yang mem-blur konten di belakangnya.
class WtGlowBlob extends StatelessWidget {
  final double size;
  final Color color;

  const WtGlowBlob({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

/// Latar dekoratif layar autentikasi: gradasi lembut di sepertiga atas layar
/// plus dua [WtGlowBlob] di sudut berlawanan.
///
/// Agnostik terhadap business logic — cukup dipasang sebagai lapisan paling
/// bawah pada [Stack] layar mana pun (login, registrasi, verifikasi OTP).
class WtAuthBackdrop extends StatelessWidget {
  const WtAuthBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final gradientColor = isDark 
        ? Colors.white.withValues(alpha: 0.03) 
        : AppColors.primary.withValues(alpha: 0.05);
        
    final blobColor1 = isDark 
        ? Colors.white.withValues(alpha: 0.05) 
        : AppColors.primary.withValues(alpha: 0.1);
        
    final blobColor2 = isDark 
        ? Colors.white.withValues(alpha: 0.03) 
        : AppColors.primaryMedium.withValues(alpha: 0.1);

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: screenHeight / 3,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  gradientColor,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -80,
          right: -80,
          child: WtGlowBlob(
            size: 256,
            color: blobColor1,
          ),
        ),
        Positioned(
          bottom: -80,
          left: -80,
          child: WtGlowBlob(
            size: 256,
            color: blobColor2,
          ),
        ),
      ],
    );
  }
}
