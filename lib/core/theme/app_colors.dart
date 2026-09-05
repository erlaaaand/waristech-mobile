import 'package:flutter/material.dart';

/// Palet monokrom hitam/putih/abu-abu — persis `mobile.css` (prototipe
/// `index.html`): satu-satunya aksen warna adalah titik hijau status aktif.
/// Nama token lama (primary/navy/warm/amber) DIPERTAHANKAN agar seluruh
/// layar yang sudah memakainya otomatis ikut berganti tema tanpa perlu
/// diedit satu-satu — hanya NILAI warnanya yang diganti di sini.
class AppColors {
  // CTA/aksi utama — prototipe: var(--black), tidak ada warna aksen biru.
  static const Color primary = Color(0xFF000000);

  // Teks & elemen gelap — prototipe: var(--black)/var(--gray-900).
  static const Color navy = Color(0xFF000000);

  // Prototipe tidak punya warna warning terpisah — dipetakan ke gray-500
  // supaya badge/ikon yang sebelumnya "amber" tetap netral, bukan biru/oranye.
  static const Color amber = Color(0xFF777777);

  // Latar lembut untuk field/kartu sekunder — prototipe: var(--gray-50).
  static const Color warm = Color(0xFFF8F8F8);

  // Surface
  static const Color surface = Color(0xFFFFFFFF);

  // Skala abu-abu persis token CSS `--gray-*` di mobile.css.
  static const Color gray50 = Color(0xFFF8F8F8);
  static const Color gray100 = Color(0xFFF2F2F2);
  static const Color gray200 = Color(0xFFE0E0E0);
  static const Color gray300 = Color(0xFFBBBBBB);
  static const Color gray400 = Color(0xFF999999);
  static const Color gray500 = Color(0xFF777777);
  static const Color gray600 = Color(0xFF555555);
  static const Color gray700 = Color(0xFF333333);
  static const Color gray800 = Color(0xFF1F1F1F);
  static const Color gray900 = Color(0xFF111111);

  // Dark mode — prototipe tidak mendefinisikan varian gelap eksplisit untuk
  // index.html, jadi diturunkan konsisten dari skala abu-abu yang sama.
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkCard = Color(0xFF111111);

  // Status colors — dipertahankan berwarna HANYA untuk umpan balik sistem
  // (snackbar error/sukses); satu-satunya aksen warna di layar statis
  // adalah titik hijau "Status Aktif" (lihat `pulseGreen`).
  static const Color success = Color(0xFF22C55E);
  static const Color danger = Color(0xFFEF4444);

  // Titik pulsa hijau status aktif — prototipe: `.pulse-dot{background:#4ade80}`.
  static const Color pulseGreen = Color(0xFF4ADE80);

  // Rose - accent khusus radio/pilihan terpilih (prototipe: .radio-ring).
  static const Color rose = Color(0xFFF43F5E);

  // Text
  static const Color textLight = navy;
  static const Color textDark = Colors.white;
}
