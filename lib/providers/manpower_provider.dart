import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../repositories/manpower_repository.dart';
import 'auth_provider.dart';
import 'filter_providers.dart';

final manpowerRepositoryProvider = Provider<ManpowerRepository>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return ManpowerRepository(authRepo);
});

class ManpowerNotifier extends AutoDisposeFamilyAsyncNotifier<List<ManpowerEntry>, String?> {
  @override
  Future<List<ManpowerEntry>> build(String? arg) async {
    final repo = ref.watch(manpowerRepositoryProvider);
    final filter = ref.watch(manpowerFilterProvider);
    return await repo.getAllManpower(subcontractorId: arg, filter: filter);
  }

  Future<void> addEntry(String name) async {
    try {
      final repo = ref.read(manpowerRepositoryProvider);
      await repo.createManpower(name);
      ref.invalidateSelf(); // Refresh the list
    } catch (e, st) {
      debugPrint('Add Manpower Error: $e');
      state = AsyncError(e, st);
    }
  }

  Future<void> updateApproval(String id, ApprovalStatus status) async {
    try {
      final repo = ref.read(manpowerRepositoryProvider);
      await repo.updateApproval(id, status);
      ref.invalidateSelf();
    } catch (e, st) {
      debugPrint('Update Approval Error: $e');
      state = AsyncError(e, st);
    }
  }

  Future<void> updateAttendance(String id, AttendanceStatus status) async {
    try {
      final repo = ref.read(manpowerRepositoryProvider);
      await repo.updateAttendance(id, status);
      ref.invalidateSelf();
    } catch (e, st) {
      debugPrint('Update Attendance Error: $e');
      state = AsyncError(e, st);
    }
  }
}

final manpowerProvider = AsyncNotifierProvider.autoDispose.family<ManpowerNotifier, List<ManpowerEntry>, String?>(() {
  return ManpowerNotifier();
});
