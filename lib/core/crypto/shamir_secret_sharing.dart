import 'dart:math' as math;

/// Port langsung (byte-exact) dari algoritma `secrets.js-grempe` yang dipakai
/// backend WarisTech untuk Shamir's Secret Sharing atas GF(2^8):
/// `wt-backend/node_modules/secrets.js-grempe/secrets.js` — dikonfirmasi
/// backend SELALU memakai pengaturan bawaannya (bits=8, radix=16, threshold
/// 2-dari-3), jadi port ini mengunci nilai tersebut alih-alih generik.
///
/// JANGAN "menyederhanakan" logika di bawah ini meski tampak janggal — banyak
/// operasi prepend-string di `str2hex`/`hex2str` dan `share`/`combine` yang
/// sengaja saling membalik urutan supaya round-trip dengan versi JS-nya persis
/// sama. Setiap perubahan wajib diuji ulang terhadap output Node asli.
class ShamirSecretSharing {
  static const int _bits = 8;
  static const int _radix = 16;
  static const int _maxShares = 255; // 2^8 - 1
  static const int _primitivePolynomial =
      29; // primitivePolynomials[8] pada secrets.js
  static const int _defaultBytesPerChar = 2;
  static const int _idHexLen = 2; // (2^8 - 1) dalam hex = "ff" = 2 digit

  static final List<int> _exps = List<int>.filled(256, 0, growable: false);
  static final List<int> _logs = List<int>.filled(256, 0, growable: false);
  static bool _tablesBuilt = false;

  static void _ensureTables() {
    if (_tablesBuilt) return;
    int x = 1;
    for (int i = 0; i < 256; i++) {
      _exps[i] = x;
      _logs[x] = i;
      x = x << 1;
      if (x >= 256) {
        x = x ^ _primitivePolynomial;
        x = x & _maxShares;
      }
    }
    _tablesBuilt = true;
  }

  // ── Helper: padding & konversi basis ────────────────────────────────────

  static String _padLeft(String str, [int multipleOfBits = _bits]) {
    if (multipleOfBits == 0 || multipleOfBits == 1) return str;
    if (str.isEmpty) return str;
    final missing = str.length % multipleOfBits;
    if (missing == 0) return str;
    return ('0' * (multipleOfBits - missing)) + str;
  }

  static String _hex2bin(String str) {
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final n = int.parse(str[i], radix: 16);
      buffer.write(_padLeft(n.toRadixString(2), 4));
    }
    return buffer.toString();
  }

  static String _bin2hex(String rawStr) {
    final str = _padLeft(rawStr, 4);
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i += 4) {
      final chunk = str.substring(i, i + 4);
      buffer.write(int.parse(chunk, radix: 2).toRadixString(16));
    }
    return buffer.toString();
  }

  /// `parts[0]` = segmen `_bits`-bit PALING KANAN dari `str` (bukan paling kiri).
  static List<int> _splitNumStringToIntArray(String rawStr, [int? padLength]) {
    final str = padLength != null ? _padLeft(rawStr, padLength) : rawStr;
    final parts = <int>[];
    int i = str.length;
    for (; i > _bits; i -= _bits) {
      parts.add(int.parse(str.substring(i - _bits, i), radix: 2));
    }
    parts.add(int.parse(str.substring(0, i), radix: 2));
    return parts;
  }

  // ── Aritmetika GF(256) ───────────────────────────────────────────────────

  static int _horner(int x, List<int> coeffs) {
    final logx = _logs[x];
    int fx = 0;
    for (int i = coeffs.length - 1; i >= 0; i--) {
      if (fx != 0) {
        fx = _exps[(logx + _logs[fx]) % _maxShares] ^ coeffs[i];
      } else {
        fx = coeffs[i];
      }
    }
    return fx;
  }

  static int _lagrange(int at, List<int> x, List<int> y) {
    int sum = 0;
    final len = x.length;
    for (int i = 0; i < len; i++) {
      if (y[i] != 0) {
        int product = _logs[y[i]];
        for (int j = 0; j < len; j++) {
          if (i != j) {
            if (at == x[j]) {
              product = -1;
              break;
            }
            product =
                (product + _logs[at ^ x[j]] - _logs[x[i] ^ x[j]] + _maxShares) %
                _maxShares;
          }
        }
        sum = product == -1 ? sum : sum ^ _exps[product];
      }
    }
    return sum;
  }

  static List<_SharePoint> _getShares(
    int secret,
    int numShares,
    int threshold,
    math.Random rng,
  ) {
    final coeffs = List<int>.filled(threshold, 0);
    coeffs[0] = secret;
    for (int i = 1; i < threshold; i++) {
      coeffs[i] = rng.nextInt(256);
    }
    return List<_SharePoint>.generate(
      numShares,
      (idx) => _SharePoint(idx + 1, _horner(idx + 1, coeffs)),
    );
  }

  // ── Format share publik: [bits-base36][id-hex 2 digit][data-hex] ───────

  static String _constructPublicShareString(int id, String data) {
    if (id < 1 || id > _maxShares) {
      throw const ShamirException(
        'Share id harus bilangan bulat 1..$_maxShares.',
      );
    }
    final bitsBase36 = _bits.toRadixString(36).toUpperCase();
    final idHex = id.toRadixString(_radix).padLeft(_idHexLen, '0');
    return bitsBase36 + idHex + data;
  }

  static ({int id, String data}) _extractShareComponents(String share) {
    if (share.length <= 1 + _idHexLen) {
      throw const ShamirException(
        'Format bagian kunci tidak valid: terlalu pendek.',
      );
    }
    final bits = int.parse(share.substring(0, 1), radix: 36);
    if (bits != _bits) {
      throw ShamirException(
        'Bagian kunci memakai pengaturan bit berbeda ($bits), diharapkan $_bits.',
      );
    }
    final idHex = share.substring(1, 1 + _idHexLen);
    final id = int.parse(idHex, radix: _radix);
    if (id < 1 || id > _maxShares) {
      throw const ShamirException('Share id harus antara 1 dan $_maxShares.');
    }
    final data = share.substring(1 + _idHexLen);
    if (data.isEmpty) {
      throw const ShamirException('Data pada bagian kunci kosong/tidak valid.');
    }
    return (id: id, data: data);
  }

  // ── API publik ───────────────────────────────────────────────────────────

  /// Konversi string menjadi hex — 1 karakter direpresentasikan `bytesPerChar`
  /// byte (default 2, sama seperti backend). CATATAN: urutan blok hex
  /// SENGAJA dibalik (prepend) relatif terhadap `hex2str` — keduanya saling
  /// membatalkan pembalikan ini, jangan diubah sendiri-sendiri.
  static String str2hex(String str, [int bytesPerChar = _defaultBytesPerChar]) {
    final hexChars = 2 * bytesPerChar;
    String out = '';
    for (int i = 0; i < str.length; i++) {
      final code = str.codeUnitAt(i);
      out = _padLeft(code.toRadixString(16), hexChars) + out;
    }
    return out;
  }

  static String hex2str(String str, [int bytesPerChar = _defaultBytesPerChar]) {
    final hexChars = 2 * bytesPerChar;
    final padded = _padLeft(str, hexChars);
    String out = '';
    for (int i = 0; i < padded.length; i += hexChars) {
      final code = int.parse(padded.substring(i, i + hexChars), radix: 16);
      out = String.fromCharCode(code) + out;
    }
    return out;
  }

  /// Pecah `secretHex` (hasil [str2hex]) menjadi `numShares` bagian, butuh
  /// `threshold` bagian untuk direkonstruksi. Selalu dipanggil dengan
  /// numShares=3, threshold=2 di WarisTech.
  static List<String> share(
    String secretHex,
    int numShares,
    int threshold, {
    int padLength = 128,
  }) {
    _ensureTables();
    if (numShares < 2 || numShares > _maxShares) {
      throw const ShamirException('Jumlah bagian harus 2..$_maxShares.');
    }
    if (threshold < 2 || threshold > numShares) {
      throw const ShamirException('Threshold harus 2..jumlah bagian.');
    }

    final rng = math.Random.secure();
    final secretBin =
        '1${_hex2bin(secretHex)}'; // marker bit menjaga leading zero
    final segments = _splitNumStringToIntArray(secretBin, padLength);

    final xVals = List<String>.filled(numShares, '');
    final yBins = List<String>.filled(numShares, '');

    for (final segment in segments) {
      final points = _getShares(segment, numShares, threshold, rng);
      for (int j = 0; j < numShares; j++) {
        if (xVals[j].isEmpty) {
          xVals[j] = points[j].x.toRadixString(_radix);
        }
        yBins[j] = _padLeft(points[j].y.toRadixString(2)) + yBins[j];
      }
    }

    return List<String>.generate(numShares, (i) {
      final id = int.parse(xVals[i], radix: _radix);
      return _constructPublicShareString(id, _bin2hex(yBins[i]));
    });
  }

  /// Rekonstruksi rahasia asli dari minimal `threshold` (2) bagian kunci.
  /// Mengembalikan hex string — panggil [hex2str] untuk mendapat plaintext.
  static String combine(List<String> shares) {
    _ensureTables();
    if (shares.length < 2) {
      throw const ShamirException('Rekonstruksi butuh minimal 2 bagian kunci.');
    }

    final xVals = <int>[];
    final ySegmentsByColumn = <List<int?>>[];
    int? expectedSegmentCount;

    for (final rawShare in shares) {
      final parsed = _extractShareComponents(rawShare);
      if (xVals.contains(parsed.id)) continue;

      final segments = _splitNumStringToIntArray(_hex2bin(parsed.data));
      expectedSegmentCount ??= segments.length;
      if (segments.length != expectedSegmentCount) {
        throw const ShamirException(
          'Bagian kunci tidak sepadan (panjang data berbeda) — kemungkinan berasal dari aset yang berbeda.',
        );
      }

      xVals.add(parsed.id);
      final col = xVals.length - 1;
      for (int j = 0; j < segments.length; j++) {
        if (ySegmentsByColumn.length <= j) {
          ySegmentsByColumn.add(List<int?>.filled(shares.length, null));
        }
        ySegmentsByColumn[j][col] = segments[j];
      }
    }

    String result = '';
    for (int i = 0; i < ySegmentsByColumn.length; i++) {
      final yRow = ySegmentsByColumn[i]
          .sublist(0, xVals.length)
          .map((v) => v ?? 0)
          .toList(growable: false);
      final byteVal = _lagrange(0, xVals, yRow);
      result = _padLeft(byteVal.toRadixString(2)) + result;
    }

    final markerIndex = result.indexOf('1');
    if (markerIndex == -1) {
      throw const ShamirException(
        'Gagal merekonstruksi kredensial — bagian kunci tidak valid atau tidak cocok satu sama lain.',
      );
    }
    return _bin2hex(result.substring(markerIndex + 1));
  }
}

class _SharePoint {
  final int x;
  final int y;
  const _SharePoint(this.x, this.y);
}

class ShamirException implements Exception {
  final String message;
  const ShamirException(this.message);
  @override
  String toString() => message;
}
