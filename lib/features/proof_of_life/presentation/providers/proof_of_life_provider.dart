import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/features/proof_of_life/data/datasources/proof_of_life_remote_data_source.dart';
import 'package:wt_mobile/features/proof_of_life/domain/entities/proof_of_life_status_entity.dart';

final _ds = ProofOfLifeRemoteDataSource();

/// Status Proof-of-Life Pewaris saat ini — GET /proof-of-life/status.
final proofOfLifeStatusProvider =
    FutureProvider.autoDispose<ProofOfLifeStatusEntity>((ref) async {
      final json = await _ds.getStatus();
      return ProofOfLifeStatusEntity.fromJson(json);
    });

/// Notifier untuk aksi Check-in (Konfirmasi Keaktifan).
class CheckInNotifier extends StateNotifier<AsyncValue<DateTime?>> {
  final Ref _ref;
  CheckInNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> checkIn() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _ds.checkIn();
      return DateTime.now();
    });
    if (!state.hasError) _ref.invalidate(proofOfLifeStatusProvider);
  }
}

final checkInProvider =
    StateNotifierProvider.autoDispose<CheckInNotifier, AsyncValue<DateTime?>>(
      (ref) => CheckInNotifier(ref),
    );
