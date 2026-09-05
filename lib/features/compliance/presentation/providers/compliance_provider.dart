import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wt_mobile/features/compliance/data/datasources/compliance_remote_data_source.dart';

final _ds = ComplianceRemoteDataSource();

/// Status persetujuan pemrosesan data pribadi (UU PDP) milik user saat ini.
final myConsentProvider = FutureProvider.autoDispose<Map<String, dynamic>>((
  ref,
) {
  return _ds.getMyConsent();
});

/// Notifier untuk memberi/memperbarui persetujuan.
class GrantConsentNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  GrantConsentNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> grant() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _ds.grantConsent());
    if (!state.hasError) _ref.invalidate(myConsentProvider);
  }
}

final grantConsentProvider =
    StateNotifierProvider.autoDispose<GrantConsentNotifier, AsyncValue<void>>(
      (ref) => GrantConsentNotifier(ref),
    );
