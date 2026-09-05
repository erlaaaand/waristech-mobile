import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/features/calculation/data/datasources/calculation_remote_data_source.dart';
import 'package:wt_mobile/features/calculation/domain/entities/calculation_result_entity.dart';

final _ds = CalculationRemoteDataSource();

/// Preferensi skema hukum waris yang TERSIMPAN di backend — bukan lagi
/// state lokal seperti sebelumnya. `null` berarti Pewaris belum menetapkan.
final calculationPreferenceProvider = FutureProvider.autoDispose<String?>(
  (ref) => _ds.getPreference(),
);

class SetPreferenceNotifier extends StateNotifier<AsyncValue<String?>> {
  final Ref _ref;
  SetPreferenceNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> setPreference(String method) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _ds.setPreference(method));
    if (!state.hasError) {
      _ref.invalidate(calculationPreferenceProvider);
    }
  }
}

final setPreferenceProvider =
    StateNotifierProvider.autoDispose<
      SetPreferenceNotifier,
      AsyncValue<String?>
    >((ref) => SetPreferenceNotifier(ref));

/// Ringkasan dashboard (jumlah aset & anggota keluarga) — GET /calculation/dashboard.
final calculationDashboardProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>(
      (ref) => _ds.getDashboard(),
    );

/// Notifier untuk simulasi pembagian waris — POST /calculation/simulate.
/// Simulasi murni (tidak disimpan), jadi state cukup di-reset tiap kali
/// layar simulasi baru dibuka (autoDispose).
class SimulateNotifier extends StateNotifier<AsyncValue<CalculationResultEntity?>> {
  SimulateNotifier() : super(const AsyncValue.data(null));

  Future<void> simulate(
    String method, {
    List<Map<String, dynamic>>? customaryRatios,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final raw = await _ds.simulate(
        method: method,
        customaryRatios: customaryRatios,
      );
      return CalculationResultEntity.fromJson(raw);
    });
  }
}

final simulateProvider =
    StateNotifierProvider.autoDispose<
      SimulateNotifier,
      AsyncValue<CalculationResultEntity?>
    >((ref) => SimulateNotifier());
