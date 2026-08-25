import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/features/verification/data/datasources/verification_remote_data_source.dart';

final _ds = VerificationRemoteDataSource();

// ---------------------------------------------------------------------------
// State untuk aksi approve/reject pada satu aset
// ---------------------------------------------------------------------------

class VerificationActionState {
  final bool isLoading;
  final String? error;
  final bool isDone;

  const VerificationActionState({
    this.isLoading = false,
    this.error,
    this.isDone = false,
  });

  VerificationActionState copyWith({bool? isLoading, String? error, bool? isDone}) =>
      VerificationActionState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        isDone: isDone ?? this.isDone,
      );
}

/// Notifier untuk aksi Verify/Reject pada satu asset ID.
class VerificationActionNotifier
    extends StateNotifier<VerificationActionState> {
  VerificationActionNotifier() : super(const VerificationActionState());

  Future<void> verify(String assetId) =>
      _act(() => _ds.verifyAsset(assetId));

  Future<void> reject(String assetId) =>
      _act(() => _ds.rejectAsset(assetId));

  Future<void> _act(Future<dynamic> Function() action) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await action();
      state = state.copyWith(isLoading: false, isDone: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

/// Provider family — satu notifier per assetId.
final verificationActionProvider = StateNotifierProvider.family
    .autoDispose<VerificationActionNotifier, VerificationActionState, String>(
  (ref, id) => VerificationActionNotifier(),
);
