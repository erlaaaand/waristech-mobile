import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/features/verification/data/datasources/verification_remote_data_source.dart';

final _dataSource = VerificationRemoteDataSource();

/// State untuk aksi approve/reject pada satu kartu verifikasi.
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

/// Notifier untuk aksi Approve/Reject pada satu ID verifikasi.
class VerificationActionNotifier
    extends StateNotifier<VerificationActionState> {
  VerificationActionNotifier() : super(const VerificationActionState());

  Future<void> approve(String id) => _act(() => _dataSource.approve(id));

  Future<void> reject(String id, String reason) =>
      _act(() => _dataSource.reject(id, reason: reason));

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

/// Provider family — satu notifier per verificationId.
final verificationActionProvider = StateNotifierProvider.family
    .autoDispose<VerificationActionNotifier, VerificationActionState, String>(
  (ref, id) => VerificationActionNotifier(),
);
