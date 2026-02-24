import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../repositories/equipment_repository.dart';
import 'auth_provider.dart';
import 'filter_providers.dart';

final equipmentRepositoryProvider = Provider<EquipmentRepository>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return EquipmentRepository(authRepo);
});

class EquipmentNotifier extends AutoDisposeFamilyAsyncNotifier<List<EquipmentEntry>, String?> {
  @override
  Future<List<EquipmentEntry>> build(String? arg) async {
    final repo = ref.watch(equipmentRepositoryProvider);
    final filter = ref.watch(equipmentFilterProvider);
    return await repo.getAllEquipment(subcontractorId: arg, filter: filter);
  }

  Future<void> addEntry(String name, String type) async {
    try {
      final repo = ref.read(equipmentRepositoryProvider);
      await repo.createEquipment(name, type);
      ref.invalidateSelf();
    } catch (e, st) {
      debugPrint('Add Equipment Error: $e');
      state = AsyncError(e, st);
    }
  }

  Future<void> updateApproval(String id, ApprovalStatus status) async {
    try {
      final repo = ref.read(equipmentRepositoryProvider);
      await repo.updateApproval(id, status);
      ref.invalidateSelf();
    } catch (e, st) {
      debugPrint('Update Equipment Approval Error: $e');
      state = AsyncError(e, st);
    }
  }

  Future<void> updateDeployment(String id, DeploymentStatus status) async {
    try {
      final repo = ref.read(equipmentRepositoryProvider);
      await repo.updateStatus(id, status);
      ref.invalidateSelf();
    } catch (e, st) {
      debugPrint('Update Equipment Status Error: $e');
      state = AsyncError(e, st);
    }
  }
}

final equipmentProvider = AsyncNotifierProvider.autoDispose.family<EquipmentNotifier, List<EquipmentEntry>, String?>(() {
  return EquipmentNotifier();
});
