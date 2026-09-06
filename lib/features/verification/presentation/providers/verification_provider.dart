import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/features/assets/domain/entities/asset_entity.dart';
import 'package:wt_mobile/features/verification/data/datasources/verification_remote_data_source.dart';

final _ds = VerificationRemoteDataSource();

/// Riwayat aset yang sudah diverifikasi/ditolak/ditutup oleh Notaris —
/// GET /assets/notaris/history.
final verificationHistoryProvider =
    FutureProvider.autoDispose<List<AssetEntity>>((ref) async {
      final raw = await _ds.fetchHistory();
      return raw
          .whereType<Map<String, dynamic>>()
          .map(AssetEntity.fromJson)
          .toList();
    });

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

  VerificationActionState copyWith({
    bool? isLoading,
    String? error,
    bool? isDone,
  }) => VerificationActionState(
    isLoading: isLoading ?? this.isLoading,
    error: error,
    isDone: isDone ?? this.isDone,
  );
}

/// Notifier untuk aksi Verify/Reject pada satu asset ID.
class VerificationActionNotifier
    extends StateNotifier<VerificationActionState> {
  VerificationActionNotifier() : super(const VerificationActionState());

  Future<void> verify(String assetId) => _act(() => _ds.verifyAsset(assetId));

  Future<void> reject(String assetId, String reason) =>
      _act(() => _ds.rejectAsset(assetId, reason));

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

/// Antrean dokumen akta kematian yang menunggu verifikasi Notaris —
/// GET /inheritance/death-certificate/notaris/pending.
final pendingDeathCertificatesProvider =
    FutureProvider.autoDispose<List<dynamic>>((ref) {
      return _ds.fetchPendingDeathCertificates();
    });

/// Verifikasi dokumen akta kematian (Notaris) — syarat pihak resmi/netral
/// sebelum brankas dapat dibuka (lihat modul Verifikasi Berjenjang backend).
/// Provider family — satu notifier per deathVerificationId, supaya beberapa
/// item di antrean tidak berbagi satu state loading/error yang sama.
class VerifyDeathCertificateNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  VerifyDeathCertificateNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> verify(String deathVerificationId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _ds.verifyDeathCertificate(deathVerificationId),
    );
    if (!state.hasError) {
      _ref.invalidate(pendingDeathCertificatesProvider);
    }
  }
}

final verifyDeathCertificateProvider = StateNotifierProvider.family
    .autoDispose<VerifyDeathCertificateNotifier, AsyncValue<void>, String>(
      (ref, id) => VerifyDeathCertificateNotifier(ref),
    );
