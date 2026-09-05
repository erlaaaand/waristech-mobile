import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/features/inheritance/data/datasources/inheritance_remote_data_source.dart';

final _ds = InheritanceRemoteDataSource();

// ---------------------------------------------------------------------------
// Providers (read-only data)
// ---------------------------------------------------------------------------

/// Daftar invitasi aktif milik Pewaris.
final invitationsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) {
  return _ds.getMyInvitations();
});

/// Daftar anggota keluarga (Ahli Waris) yang sudah mendaftar.
final familyMembersProvider = FutureProvider.autoDispose<List<dynamic>>((ref) {
  return _ds.getFamilyMembers();
});

/// (Ahli Waris) Status keanggotaan keluarga saya sendiri — Pewaris yang
/// mengundang, hubungan, dan status verifikasi. Biasanya berisi 1 entri.
final myFamilyMembershipProvider = FutureProvider.autoDispose<List<dynamic>>((
  ref,
) {
  return _ds.getMyFamilyMembership();
});

// ---------------------------------------------------------------------------
// Notifier untuk generate invitation
// ---------------------------------------------------------------------------

class GenerateInvitationState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? result;

  const GenerateInvitationState({
    this.isLoading = false,
    this.error,
    this.result,
  });

  GenerateInvitationState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? result,
  }) => GenerateInvitationState(
    isLoading: isLoading ?? this.isLoading,
    error: error,
    result: result ?? this.result,
  );
}

class GenerateInvitationNotifier
    extends StateNotifier<GenerateInvitationState> {
  GenerateInvitationNotifier() : super(const GenerateInvitationState());

  Future<void> generate({
    required String relationshipType,
    required String relationshipDescription,
    String? supportingDocumentUrl,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _ds.generateInvitation(
        relationshipType: relationshipType,
        relationshipDescription: relationshipDescription,
        supportingDocumentUrl: supportingDocumentUrl,
      );
      state = state.copyWith(isLoading: false, result: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() => state = const GenerateInvitationState();
}

final generateInvitationProvider =
    StateNotifierProvider.autoDispose<
      GenerateInvitationNotifier,
      GenerateInvitationState
    >((ref) => GenerateInvitationNotifier());

// ---------------------------------------------------------------------------
// Notifier untuk konfirmasi anggota keluarga
// ---------------------------------------------------------------------------

class ConfirmMemberNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  ConfirmMemberNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> confirm(String memberId) async {
    state = const AsyncValue.loading();
    try {
      await _ds.confirmFamilyMember(memberId);
      state = const AsyncValue.data(null);
      // Refresh family members list setelah konfirmasi
      _ref.invalidate(familyMembersProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final confirmMemberProvider =
    StateNotifierProvider.autoDispose<ConfirmMemberNotifier, AsyncValue<void>>(
      (ref) => ConfirmMemberNotifier(ref),
    );

// ---------------------------------------------------------------------------
// (NOTARIS) Antrean verifikasi relasi keluarga Non-Nasab
// ---------------------------------------------------------------------------

/// Antrean relasi Non-Nasab lintas Pewaris yang menunggu verifikasi Notaris —
/// GET /inheritance/family-members/notaris/pending.
final pendingFamilyMembersProvider =
    FutureProvider.autoDispose<List<dynamic>>((ref) {
      return _ds.getPendingFamilyMembersNotaris();
    });

/// State aksi Verify/Reject untuk satu relasi keluarga — pola sama seperti
/// `VerificationActionState`/`VerificationActionNotifier` di modul assets.
class FamilyMemberActionState {
  final bool isLoading;
  final String? error;
  final bool isDone;

  const FamilyMemberActionState({
    this.isLoading = false,
    this.error,
    this.isDone = false,
  });

  FamilyMemberActionState copyWith({
    bool? isLoading,
    String? error,
    bool? isDone,
  }) => FamilyMemberActionState(
    isLoading: isLoading ?? this.isLoading,
    error: error,
    isDone: isDone ?? this.isDone,
  );
}

class FamilyMemberActionNotifier
    extends StateNotifier<FamilyMemberActionState> {
  FamilyMemberActionNotifier() : super(const FamilyMemberActionState());

  Future<void> verify(String id) => _act(() => _ds.verifyFamilyMember(id));

  Future<void> reject(String id) => _act(() => _ds.rejectFamilyMember(id));

  Future<void> _act(Future<void> Function() action) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await action();
      state = state.copyWith(isLoading: false, isDone: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final familyMemberActionProvider = StateNotifierProvider.family
    .autoDispose<FamilyMemberActionNotifier, FamilyMemberActionState, String>(
      (ref, id) => FamilyMemberActionNotifier(),
    );

// ---------------------------------------------------------------------------
// Saksi / Kontak Darurat & Akta Kematian
// ---------------------------------------------------------------------------

/// Daftar Saksi/Kontak Darurat milik Pewaris.
final witnessesProvider = FutureProvider.autoDispose<List<dynamic>>((ref) {
  return _ds.getMyWitnesses();
});

class RegisterWitnessNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  RegisterWitnessNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> register({
    required String name,
    required String email,
    required String phone,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _ds.registerWitness(name: name, email: email, phone: phone),
    );
    if (!state.hasError) _ref.invalidate(witnessesProvider);
  }
}

final registerWitnessProvider =
    StateNotifierProvider.autoDispose<
      RegisterWitnessNotifier,
      AsyncValue<void>
    >((ref) => RegisterWitnessNotifier(ref));

class SubmitDeathCertificateNotifier extends StateNotifier<AsyncValue<void>> {
  SubmitDeathCertificateNotifier() : super(const AsyncValue.data(null));

  Future<void> submit({
    required String pewarisId,
    required String documentUrl,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _ds.submitDeathCertificate(
        pewarisId: pewarisId,
        documentUrl: documentUrl,
      ),
    );
  }
}

final submitDeathCertificateProvider =
    StateNotifierProvider.autoDispose<
      SubmitDeathCertificateNotifier,
      AsyncValue<void>
    >((ref) => SubmitDeathCertificateNotifier());

/// Keputusan Saksi (APPROVE/DISPUTE) — dipanggil dari alur Guest (magic link).
class WitnessDecisionNotifier extends StateNotifier<AsyncValue<void>> {
  WitnessDecisionNotifier() : super(const AsyncValue.data(null));

  Future<void> submit({
    required String witnessId,
    required String decision,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _ds.submitWitnessDecision(witnessId: witnessId, decision: decision),
    );
  }
}

final witnessDecisionProvider =
    StateNotifierProvider.autoDispose<
      WitnessDecisionNotifier,
      AsyncValue<void>
    >((ref) => WitnessDecisionNotifier());
