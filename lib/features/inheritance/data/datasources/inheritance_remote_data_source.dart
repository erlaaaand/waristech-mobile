import 'package:wt_mobile/core/network/base_remote_data_source.dart';

/// Remote data source untuk fitur pewarisan (invitasi & anggota keluarga).
class InheritanceRemoteDataSource extends BaseRemoteDataSource {
  /// GET /inheritance/invitations — daftar kode undangan Pewaris.
  Future<List<dynamic>> getMyInvitations() {
    return safeCall(() async {
      final response = await dio.get('/inheritance/invitations');
      final unwrapped = unwrapData(response.data);
      return unwrapped is List ? unwrapped : [];
    });
  }

  /// POST /inheritance/invitations — buat kode undangan baru.
  Future<Map<String, dynamic>> generateInvitation({
    required String label,
    required String relationshipType,
  }) {
    return safeCall(() async {
      final response = await dio.post('/inheritance/invitations', data: {
        'label': label,
        'relationshipType': relationshipType,
      });
      return response.data as Map<String, dynamic>? ?? {};
    });
  }

  /// GET /inheritance/family-members — daftar ahli waris yang terdaftar.
  Future<List<dynamic>> getFamilyMembers() {
    return safeCall(() async {
      final response = await dio.get('/inheritance/family-members');
      final unwrapped = unwrapData(response.data);
      return unwrapped is List ? unwrapped : [];
    });
  }

  /// PATCH /inheritance/family-members/:id/confirm — konfirmasi anggota keluarga.
  Future<void> confirmFamilyMember(String memberId) {
    return safeCall(() async {
      await dio.patch('/inheritance/family-members/$memberId/confirm');
    });
  }
}
