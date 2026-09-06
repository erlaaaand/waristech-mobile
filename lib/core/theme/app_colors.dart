import 'package:flutter/material.dart';

/// Blue Design System — WarisTech
///
/// Palet utama biru profesional 6 tingkat, ditambah token semantik untuk
/// background, surface, divider, teks, dan dark mode. Nama token lama
/// (`primary`, `navy`, `amber`, `warm`, `surface`) dipertahankan sebagai
/// alias agar 350+ referensi di seluruh app otomatis mengikuti tanpa perlu
/// diedit satu-satu.
class AppColors {
  // ── Blue Palette (6 tingkat) ──────────────────────────────────────────
  static const Color primaryLightest = Color(0xFFC0E6FD); // Highlight / light surface
  static const Color primaryLight    = Color(0xFF80AAD3); // Secondary / softer primary
  static const Color primaryMedium   = Color(0xFF5B86B6); // Interactive / supporting
  static const Color primary         = Color(0xFF3F6593); // Primary CTA
  static const Color primaryDark     = Color(0xFF1B3554); // Dark surface / emphasis
  static const Color primaryDeep     = Color(0xFF000F22); // Deepest text / dark background

  // ── Legacy Aliases ────────────────────────────────────────────────────
  // Dipertahankan supaya file-file lama yang mereferensikan token ini
  // otomatis ikut berubah ke nuansa biru tanpa perlu migrasi manual.
  static const Color navy = primaryDeep;
  static const Color amber = primaryMedium;
  static const Color warm = Color(0xFFF6FAFE); // fill field, blue-tinted warm
  static const Color surface = Color(0xFFFFFFFF);

  // ── Semantic Tokens ───────────────────────────────────────────────────
  static const Color background    = Color(0xFFF6FAFE); // Scaffold light
  static const Color divider       = Color(0xFFD8E4EF); // Border / separator
  static const Color textPrimary   = primaryDeep;        // Highest contrast text
  static const Color textSecondary = primary;            // Secondary text
  static const Color textMuted     = primaryMedium;      // Muted / caption text
  static const Color textOnPrimary = Color(0xFFFFFFFF);  // Text on primary surfaces

  // ── Gray Scale ────────────────────────────────────────────────────────
  // Dipertahankan untuk konteks netral murni (shadow, disabled, skeleton).
  static const Color gray50  = Color(0xFFF8F8F8);
  static const Color gray100 = Color(0xFFF2F2F2);
  static const Color gray200 = Color(0xFFE0E0E0);
  static const Color gray300 = Color(0xFFBBBBBB);
  static const Color gray400 = Color(0xFF999999);
  static const Color gray500 = Color(0xFF777777);
  static const Color gray600 = Color(0xFF555555);
  static const Color gray700 = Color(0xFF333333);
  static const Color gray800 = Color(0xFF1F1F1F);
  static const Color gray900 = Color(0xFF111111);

  // ── Dark Mode ─────────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF000F22); // primaryDeep
  static const Color darkSurface    = Color(0xFF1B3554); // primaryDark
  static const Color darkCard       = Color(0xFF0A1929); // Between deep & dark

  // ── Status Colors ─────────────────────────────────────────────────────
  // TIDAK diubah — warna semantik harus tetap bisa dibedakan.
  static const Color success    = Color(0xFF22C55E);
  static const Color danger     = Color(0xFFEF4444);
  static const Color pulseGreen = Color(0xFF4ADE80);

  // Radio / pilihan terpilih — diselaraskan ke palet biru.
  static const Color rose = Color(0xFF5B86B6); // primaryMedium

  // ── Text Convenience ──────────────────────────────────────────────────
  static const Color textLight = primaryDeep;
  static const Color textDark  = Colors.white;
}
