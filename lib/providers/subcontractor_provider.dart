import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../repositories/subcontractor_repository.dart';
import 'auth_provider.dart';
import 'filter_providers.dart';

final subcontractorRepositoryProvider = Provider<SubcontractorRepository>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return SubcontractorRepository(authRepo);
});

class SubcontractorsNotifier extends AsyncNotifier<List<Subcontractor>> {
  @override
  Future<List<Subcontractor>> build() async {
    final repo = ref.watch(subcontractorRepositoryProvider);
    final filter = ref.watch(subcontractorFilterProvider);
    return repo.getSubcontractors(filter: filter);
  }

  Future<void> createSubcontractor({
    required String username,
    required String password,
    required String companyName,
    required String contactPerson,
    required String phoneNumber,
  }) async {
    try {
      final repo = ref.read(subcontractorRepositoryProvider);
      await repo.createSubcontractor(
        username: username,
        password: password,
        companyName: companyName,
        contactPerson: contactPerson,
        phoneNumber: phoneNumber,
      );
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateSubcontractor(String id, {
    required String companyName,
    required String contactPerson,
    required String phoneNumber,
  }) async {
    try {
      final repo = ref.read(subcontractorRepositoryProvider);
      await repo.updateSubcontractor(
        id,
        companyName: companyName,
        contactPerson: contactPerson,
        phoneNumber: phoneNumber,
      );
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteSubcontractor(String id) async {
    try {
      final repo = ref.read(subcontractorRepositoryProvider);
      await repo.deleteSubcontractor(id);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final subcontractorsProvider = AsyncNotifierProvider<SubcontractorsNotifier, List<Subcontractor>>(() {
  return SubcontractorsNotifier();
});

// Selection providers for hierarchical Admin views
final selectedSubcontractorManpowerProvider = StateProvider<Subcontractor?>((ref) => null);
final selectedSubcontractorEquipmentProvider = StateProvider<Subcontractor?>((ref) => null);
