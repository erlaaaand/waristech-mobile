import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:wt_mobile/core/network/base_remote_data_source.dart';

/// Kategori dokumen yang diunggah — harus cocok dengan `FilePurpose` di
/// backend (`stored-file.enum.ts`). Backend belum punya purpose khusus untuk
/// bukti pencairan, jadi dipetakan ke `OTHER` + context pembeda.
enum UploadPurpose {
  deathCertificate('DEATH_CERTIFICATE', 'death-certificates'),
  familyDocument('OTHER', 'family-documents'),
  profilePhoto('PROFILE_PHOTO', 'profile-photos'),
  other('OTHER', 'liquidation-proofs');

  final String value;
  final String context;
  const UploadPurpose(this.value, this.context);
}

/// Helper generik untuk `POST /storage/upload` (multipart) — dipakai bersama
/// oleh alur akta kematian (Fase 6) dan bukti pencairan (Fase 7).
class StorageUploadService extends BaseRemoteDataSource {
  Future<void> _ensureCsrf() async {
    try {
      await dio.get<dynamic>('/csrf-token');
    } catch (_) {
      // best-effort — DioClient sudah menyimpan token CSRF sejak login.
    }
  }

  /// Buka file picker (PDF/JPG/PNG) lalu upload ke storage generik.
  /// Mengembalikan `fileUrl` hasil upload, atau null jika user membatalkan.
  Future<String?> pickAndUpload(UploadPurpose purpose) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;
    final picked = result.files.single;
    final bytes = picked.bytes;
    if (bytes == null) {
      throw Exception('Gagal membaca berkas yang dipilih.');
    }
    return uploadBytes(bytes, picked.name, purpose);
  }

  /// Upload byte berkas yang sudah dipilih (mis. lewat `file_picker` milik
  /// caller sendiri) ke storage generik. Mengembalikan `fileUrl` hasil upload.
  Future<String> uploadBytes(
    List<int> bytes,
    String filename,
    UploadPurpose purpose,
  ) {
    return safeCall(() async {
      await _ensureCsrf();
      final formData = FormData.fromMap({
        'purpose': purpose.value,
        'context': purpose.context,
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      });
      final response = await dio.post<dynamic>(
        '/storage/upload',
        data: formData,
      );
      final data = unwrapData(response.data) as Map<String, dynamic>;
      return data['fileUrl'] as String;
    });
  }
}
