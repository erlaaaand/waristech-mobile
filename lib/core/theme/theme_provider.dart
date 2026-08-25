import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Provider untuk kontrol tema aplikasi (light/dark/system).
/// Persisten menggunakan FlutterSecureStorage.
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const _key = 'themeMode';
  final _storage = const FlutterSecureStorage();

  ThemeNotifier() : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final saved = await _storage.read(key: _key);
    state = _fromString(saved);
  }

  Future<void> setLight() => _set(ThemeMode.light);
  Future<void> setDark() => _set(ThemeMode.dark);
  Future<void> setSystem() => _set(ThemeMode.system);

  /// Toggle antara light dan dark (paling sering dipakai dari AppBar).
  Future<void> toggle(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await _set(isDark ? ThemeMode.light : ThemeMode.dark);
  }

  Future<void> _set(ThemeMode mode) async {
    state = mode;
    await _storage.write(key: _key, value: _toString(mode));
  }

  static ThemeMode _fromString(String? val) {
    switch (val) {
      case 'light':  return ThemeMode.light;
      case 'dark':   return ThemeMode.dark;
      default:       return ThemeMode.system;
    }
  }

  static String _toString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:  return 'light';
      case ThemeMode.dark:   return 'dark';
      default:               return 'system';
    }
  }
}
