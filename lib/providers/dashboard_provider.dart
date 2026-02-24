import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/dashboard_repository.dart';
import 'auth_provider.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return DashboardRepository(authRepo);
});

// A future provider that fetches the latest metrics from the backend 
// whenever the user is logged in
final dashboardMetricsProvider = FutureProvider.autoDispose<DashboardMetrics?>((ref) async {
  final user = ref.watch(authProvider).value;
  if (user == null) return null;

  final repo = ref.watch(dashboardRepositoryProvider);
  return await repo.getMetrics(user.role);
});
