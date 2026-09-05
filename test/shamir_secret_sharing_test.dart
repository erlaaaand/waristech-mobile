import 'package:flutter_test/flutter_test.dart';
import 'package:wt_mobile/core/crypto/shamir_secret_sharing.dart';

/// Vektor uji NYATA — dihasilkan langsung dari backend (`secrets.js-grempe`
/// via Node) di sesi yang sama dengan port Dart ini, bukan dikarang manual.
/// Regenerasi: lihat `wt-backend`, jalankan `secrets.share(secrets.str2hex(plain), 3, 2)`.
///
/// Tes ini adalah gerbang Fase 0 — kalau ada satu saja yang gagal, JANGAN
/// lanjut membangun UI brankas (Fase 3) di atas port yang belum terbukti benar.
class _Vector {
  final String plain;
  final List<String> shares;
  const _Vector(this.plain, this.shares);
}

const _vectors = [
  _Vector('{"username":"budi","password":"RahasiaKu123","pin":"123456"}', [
    '8018bd55cdfd9295726f23898455de8856bd7d744bf7ab24bfbd16e852708d659d3833eb9c9b7861b96951d35a36d445127c48773a15d934f2fe26f8982ad4c085eddcb70b5c329cf71a838463b633c112229a9a1da9e6ab07d82576eb6d112ee72546009909145cadcb4ab5ce8af5e91e45cc18d3cb1c4daa9e7ab58b6ae32b22d',
    '8020bb7b8a3af52ae4ff9f72decba971789b3ef8836f42f96b8bfba170010d7b2091bc76f1f73773645375c6a0edadea21d958ce682ba989ee5d94b0fba4720101fa77de0119b1c83844ddc8ce0c6c922dd52da5f3c21777d6a19c8dc05bf42c15fa86c12a23f2c89c37505b8ab43133f62b83c07ca7f03a9e0d3deb0ee410279d7',
    '8038062e47c767bf9680bb2b58be74992d7640cccba8eafdd726ef6921d1823ebb49890d6a6c4d32dffa2635f9eb7a8f30b517e9568e76ad1a33b578659ea0418207ae49086580f4cd7e580caa9a59a33887b00fe95bf7ccd679bbdb29f6e722f44fc681b47ae0b433dc194e461ec28aeebe49c8a98ceb5732c3406e82def12cb81',
  ]),
  _Vector(
    '{"username":"a","password":"x","pin":"0000","notes":"catatan dengan spasi dan simbol !@#%^&*()"}',
    [
      '801e2c79d1eb7c78d913f61a8f1cbe0982239bdca13bea51cfcf7ed9aeb3292ea0b4d9dc75004ad1def82c1aef1ecaf381a0567b747c6f867a0f74d8de5fca67ba00f01dd106bfadd3fd84540b42a8e09d30d9f4566b7fdaac1e25ccd6782d86a32ee65ceb632519d4d58e24b6aee7b782641df7473acbdc24268efab593507678cde7680a3c7e1e695f0cb23063fa69d8cc4dacacc793957c8784e55d1934229df893fab43c57c721e7038c15aa63a123c662ebf0bd7a7c9148aa63bacc4396c03280ebad021a0fc60c87d66803e723c12',
      '802d993273c7393073f7ec24dff8bdd2d4772e08940612c389df3b929a164dbc9799a42936008243aa3192b414ec5e570830a75731b918dceeff339077be531f6e61e97a783d679a7ebadea80c754a212121a918a63734b49ffd90a876d1931d4c7c15681d2640727fcb09796b2c163f0e3823fe85745d599e2d0b74bd46a5ece55a1bc1d0b93b9d179fded46be7eea279595cf89f1f214ae05f0faaaf13be2520f0fe84b379761e4a9e0e59f1751e4241ecc286370b3f08f4e091f762395ddd8b150bf690f42cbe56f8d6fcc827c8278a9',
      '8033b54ba22c4548aae41a3e50e403db5644b204371dfa02449047eb36c56172357d7fc54700ca8276c9b86efd0292848f40f7bc42f5755a92104158afa19b78d2f11e57af2bdf37aa7758fc01d7e4d1ba61760cf60c4d2e31e3b384a6b9b9dbe942f474f055635ba93e84fddfa2f6b88a0c3949c4be9065b82b874e0af5f69a9e97ffa9d98547a37d60d0465d64125ba69513743118b0ff9b58896ff1aa8827bb486a5e01b526a96c490ae5e2cf7ae3600aa2adc596436467883834dad5181b4df78d0d3b16319196a4561aa7742d244c0',
    ],
  ),
  _Vector('plaintext pendek', [
    '8018b58b2e19b8ed9a7d00b3c0b13be4e7d93ddf210dbeeaab697bebd4df073c85f79f5abc9aa8d530587592f36fa3dbe2e',
    '8020bb079df2b01af53bd16781626619cf93b1af98fab6d49c333ce670afd868d22f27f4b20499ba6b813095ecfe9ce61cc',
    '80380e8cb3eb08f76f46d1d441d35dfd285a8ac0bfa70e7e31ba415da370dd545098bf2e08ce362f5d394397198139fdf92',
  ]),
  _Vector('', [
    '801aad0a45f70ff5ce80f940186d32d8cd7',
    '80249bd55bee0e3b8cd1e350211bb5a05b0',
    '803e36df1e1901ce42511a1039768778966',
  ]),
];

void main() {
  group('ShamirSecretSharing.combine — cocok dengan output backend Node', () {
    for (var v = 0; v < _vectors.length; v++) {
      final vector = _vectors[v];
      final label = vector.plain.isEmpty ? '(string kosong)' : vector.plain;

      test('vektor #$v [$label]: kombinasi mana pun dari 2-dari-3 benar', () {
        final pairs = [
          [vector.shares[0], vector.shares[1]],
          [vector.shares[0], vector.shares[2]],
          [vector.shares[1], vector.shares[2]],
        ];

        for (final pair in pairs) {
          final combinedHex = ShamirSecretSharing.combine(pair);
          final plaintext = ShamirSecretSharing.hex2str(combinedHex);
          expect(
            plaintext,
            equals(vector.plain),
            reason: 'Kombinasi $pair gagal merekonstruksi vektor #$v',
          );
        }

        // Ketiganya sekaligus juga harus tetap benar.
        final all = ShamirSecretSharing.combine(vector.shares);
        expect(ShamirSecretSharing.hex2str(all), equals(vector.plain));
      });

      test('vektor #$v [$label]: 1 share tidak boleh cukup', () {
        expect(
          () {
            final combined = ShamirSecretSharing.combine([vector.shares[0]]);
            return ShamirSecretSharing.hex2str(combined);
          },
          throwsA(isA<ShamirException>()),
          reason:
              'combine() dengan <2 share wajib menolak, bukan diam-diam salah',
        );
      });
    }
  });

  group('ShamirSecretSharing.share — round-trip mandiri (pecah lalu gabung sendiri)', () {
    test(
      'hasil share() sendiri bisa direkonstruksi kembali oleh combine()',
      () {
        const plain = 'Uji round-trip lengkap dari sisi Dart sendiri.';
        final hex = ShamirSecretSharing.str2hex(plain);
        final shares = ShamirSecretSharing.share(hex, 3, 2);

        expect(shares, hasLength(3));

        final combined = ShamirSecretSharing.combine([shares[0], shares[2]]);
        expect(ShamirSecretSharing.hex2str(combined), equals(plain));
      },
    );

    test('str2hex/hex2str round-trip untuk berbagai karakter', () {
      for (final s in [
        'sederhana',
        'dengan angka 123456',
        'simbol !@#%^&*()_+-=',
        'ç, é, ü — unicode dasar',
        '',
      ]) {
        final hex = ShamirSecretSharing.str2hex(s);
        expect(ShamirSecretSharing.hex2str(hex), equals(s));
      }
    });
  });
}
