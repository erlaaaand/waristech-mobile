import 'package:wt_mobile/core/network/base_remote_data_source.dart';

/// Remote data source untuk fitur pewarisan (invitasi & anggota keluarga).
class InheritanceRemoteDataSource extends BaseRemoteDataSource {
  /// GET /inheritance/invitations — daftar kode undangan Pewaris.
  Future<List<dynamic>> getMyInvitations() {
    return safeCall(() async {
      final response = await dio.get<dynamic>('/inheritance/invitations');
      final unwrapped = unwrapData(response.data);
      return unwrapped is List ? unwrapped : [];
    });
  }

  /// POST /inheritance/invitations — buat kode+link undangan baru.
  /// `supportingDocumentUrl` WAJIB diisi bila `relationshipType` NON_NASAB.
  Future<Map<String, dynamic>> generateInvitation({
    required String relationshipType,
    required String relationshipDescription,
    String? supportingDocumentUrl,
  }) {
    return safeCall(() async {
      await _ensureCsrf();
      final response = await dio.post<dynamic>(
        '/inheritance/invitations',
        data: {
          'relationshipType': relationshipType,
          'relationshipDescription': relationshipDescription,
          if (supportingDocumentUrl != null && supportingDocumentUrl.isNotEmpty)
            'supportingDocumentUrl': supportingDocumentUrl,
        },
      );
      return unwrapData(response.data) as Map<String, dynamic>? ?? {};
    });
  }

  /// GET /inheritance/family-members — daftar ahli waris yang terdaftar.
  Future<List<dynamic>> getFamilyMembers() {
    return safeCall(() async {
      final response = await dio.get<dynamic>('/inheritance/family-members');
      final unwrapped = unwrapData(response.data);
      return unwrapped is List ? unwrapped : [];
    });
  }

  /// GET /inheritance/family-members/me — (Ahli Waris) status keanggotaan
  /// keluarga saya sendiri: Pewaris yang mengundang, hubungan, dan status.
  Future<List<dynamic>> getMyFamilyMembership() {
    return safeCall(() async {
      final response = await dio.get<dynamic>('/inheritance/family-members/me');
      final unwrapped = unwrapData(response.data);
      return unwrapped is List ? unwrapped : [];
    });
  }

  /// PATCH /inheritance/family-members/:id/confirm — konfirmasi anggota keluarga.
  Future<void> confirmFamilyMember(String memberId) {
    return safeCall(() async {
      await dio.patch<dynamic>('/inheritance/family-members/$memberId/confirm');
    });
  }

  /// GET /inheritance/family-members/notaris/pending — (NOTARIS) antrean
  /// relasi Non-Nasab lintas Pewaris yang menunggu verifikasi.
  Future<List<dynamic>> getPendingFamilyMembersNotaris() {
    return safeCall(() async {
      final response = await dio.get<dynamic>(
        '/inheritance/family-members/notaris/pending',
      );
      final unwrapped = unwrapData(response.data);
      return unwrapped is List ? unwrapped : [];
    });
  }

  /// PATCH /inheritance/family-members/:id/verify — (NOTARIS) setujui relasi Non-Nasab.
  Future<void> verifyFamilyMember(String memberId) {
    return safeCall(() async {
      await _ensureCsrf();
      await dio.patch<dynamic>('/inheritance/family-members/$memberId/verify');
    });
  }

  /// PATCH /inheritance/family-members/:id/reject — (NOTARIS) tolak relasi Non-Nasab.
  Future<void> rejectFamilyMember(String memberId) {
    return safeCall(() async {
      await _ensureCsrf();
      await dio.patch<dynamic>('/inheritance/family-members/$memberId/reject');
    });
  }

  Future<void> _ensureCsrf() async {
    try {
      await dio.get<dynamic>('/csrf-token');
    } catch (_) {
      // best-effort
    }
  }

  /// GET /inheritance/witnesses — daftar Saksi/Kontak Darurat milik Pewaris.
  Future<List<dynamic>> getMyWitnesses() {
    return safeCall(() async {
      final response = await dio.get<dynamic>('/inheritance/witnesses');
      final unwrapped = unwrapData(response.data);
      return unwrapped is List ? unwrapped : [];
    });
  }

  /// POST /inheritance/witnesses — daftarkan Saksi/Kontak Darurat baru.
  /// Backend menolak (409) bila email ternyata milik ahli waris sendiri.
  Future<void> registerWitness({
    required String name,
    required String email,
    required String phone,
  }) {
    return safeCall(() async {
      await _ensureCsrf();
      await dio.post<dynamic>(
        '/inheritance/witnesses',
        data: {'name': name, 'email': email, 'phone': phone},
      );
    });
  }

  /// POST /inheritance/death-certificate — ajukan dokumen akta kematian.
  Future<void> submitDeathCertificate({
    required String pewarisId,
    required String documentUrl,
  }) {
    return safeCall(() async {
      await _ensureCsrf();
      await dio.post<dynamic>(
        '/inheritance/death-certificate',
        data: {'pewarisId': pewarisId, 'documentUrl': documentUrl},
      );
    });
  }

  /// POST /inheritance/witness/decision — keputusan Saksi (APPROVE/DISPUTE).
  /// Dipanggil dari alur Guest (magic link), bukan dari sesi normal.
  Future<void> submitWitnessDecision({
    required String witnessId,
    required String decision,
  }) {
    return safeCall(() async {
      await _ensureCsrf();
      await dio.post<dynamic>(
        '/inheritance/witness/decision',
        data: {'witnessId': witnessId, 'decision': decision},
      );
    });
  }
}
