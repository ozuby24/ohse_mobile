import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../core/token_storage.dart';
import '../models/dashboard_stats.dart';
import '../models/incident.dart';
import '../models/inspection.dart';
import '../models/named_ref.dart';
import '../models/permit.dart';
import '../services/ohse_api.dart';
import '../services/photo_storage.dart';
import 'auth_controller.dart';

// ---- Infrastructure ----
final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(ref.watch(tokenStorageProvider)),
);

final ohseApiProvider = Provider<OhseApi>(
  (ref) => OhseApi(ref.watch(apiClientProvider)),
);

final photoStorageProvider = Provider<PhotoStorage>((ref) => PhotoStorage());

// ---- Auth ----
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    ref.watch(ohseApiProvider),
    ref.watch(tokenStorageProvider),
  );
});

// ---- Data (auto-dispose futures, refreshable via ref.invalidate) ----
final dashboardProvider = FutureProvider.autoDispose<DashboardStats>((ref) {
  return ref.watch(ohseApiProvider).dashboard();
});

/// Active severity filter for the incidents list (null = all).
final incidentFilterProvider = StateProvider<String?>((ref) => null);

final incidentsProvider = FutureProvider.autoDispose<List<Incident>>((ref) {
  final severity = ref.watch(incidentFilterProvider);
  return ref.watch(ohseApiProvider).incidents(severity: severity);
});

final permitsProvider = FutureProvider.autoDispose<List<Permit>>((ref) {
  return ref.watch(ohseApiProvider).permits();
});

final inspectionsProvider = FutureProvider.autoDispose<List<Inspection>>((ref) {
  return ref.watch(ohseApiProvider).inspections();
});

// ---- Lookups (kept alive; rarely change) ----
final sitesProvider = FutureProvider<List<NamedRef>>((ref) {
  return ref.watch(ohseApiProvider).sites();
});

final companiesProvider = FutureProvider<List<NamedRef>>((ref) {
  return ref.watch(ohseApiProvider).companies();
});
