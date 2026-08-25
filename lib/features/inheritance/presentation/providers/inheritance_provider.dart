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
  }) =>
      GenerateInvitationState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        result: result ?? this.result,
      );
}

class GenerateInvitationNotifier
    extends StateNotifier<GenerateInvitationState> {
  GenerateInvitationNotifier() : super(const GenerateInvitationState());

  Future<void> generate({
    required String label,
    required String relationshipType,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _ds.generateInvitation(
        label: label,
        relationshipType: relationshipType,
      );
      state = state.copyWith(isLoading: false, result: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() => state = const GenerateInvitationState();
}

final generateInvitationProvider = StateNotifierProvider.autoDispose<
    GenerateInvitationNotifier, GenerateInvitationState>(
  (ref) => GenerateInvitationNotifier(),
);

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

final confirmMemberProvider = StateNotifierProvider.autoDispose<
    ConfirmMemberNotifier, AsyncValue<void>>(
  (ref) => ConfirmMemberNotifier(ref),
);

