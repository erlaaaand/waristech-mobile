/// Format kanonik nomor HP di seluruh sistem: E.164 Indonesia, mis.
/// "+6281234567890" — sama seperti yang divalidasi di wt-backend
/// (`PhoneNumberUtil`). Input pengguna ("08xx", "62xx", "+62xx", dengan
/// spasi/tanda hubung) dikonversi ke bentuk ini sebelum dikirim ke API.
class PhoneNumberUtils {
  PhoneNumberUtils._();

  static const _countryCode = '62';
  static final _pattern = RegExp(r'^\+628\d{8,11}$');

  /// Normalisasi ke format E.164 (+62...). Null jika bukan nomor HP
  /// Indonesia yang valid.
  static String? normalize(String input) {
    var digits = input.replaceAll(RegExp(r'[\s-]'), '');
    if (digits.startsWith('+')) digits = digits.substring(1);

    if (digits.startsWith('0')) {
      digits = _countryCode + digits.substring(1);
    } else if (digits.startsWith('8')) {
      digits = _countryCode + digits;
    }

    if (digits.isEmpty || !RegExp(r'^\d+$').hasMatch(digits)) return null;

    final normalized = '+$digits';
    return isValid(normalized) ? normalized : null;
  }

  /// Cek apakah nilai SUDAH dalam format kanonik +62 yang valid.
  static bool isValid(String value) => _pattern.hasMatch(value);

  /// Validator siap pakai untuk `TextFormField.validator` — kosong dianggap
  /// invalid oleh pemanggil yang mewajibkan field ini (bukan tanggung jawab
  /// util ini menentukan wajib/opsional).
  static String? validator(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'No. HP tidak boleh kosong';
    if (normalize(trimmed) == null) {
      return 'Format nomor HP tidak valid. Contoh: 081234567890';
    }
    return null;
  }
}
