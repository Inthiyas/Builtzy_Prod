import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterState {
  final String search;
  final String status; // 'all', 'approved', 'pending', 'rejected'
  final String status2; // For manpower: 'all', 'present', 'absent', 'not_marked'. For equipment: 'all', 'deployed', 'non_deployed', 'under_repair'

  const FilterState({
    this.search = '',
    this.status = 'all',
    this.status2 = 'all',
  });

  FilterState copyWith({
    String? search,
    String? status,
    String? status2,
  }) {
    return FilterState(
      search: search ?? this.search,
      status: status ?? this.status,
      status2: status2 ?? this.status2,
    );
  }
}

class SubcontractorFilter {
  final String search;
  final String manpowerRange; // e.g. '', '0-10', '11-50', '51+'
  final String equipmentRange;

  const SubcontractorFilter({
    this.search = '',
    this.manpowerRange = 'all',
    this.equipmentRange = 'all',
  });

  SubcontractorFilter copyWith({
    String? search,
    String? manpowerRange,
    String? equipmentRange,
  }) {
    return SubcontractorFilter(
      search: search ?? this.search,
      manpowerRange: manpowerRange ?? this.manpowerRange,
      equipmentRange: equipmentRange ?? this.equipmentRange,
    );
  }
}

final manpowerFilterProvider = StateProvider.autoDispose<FilterState>((ref) => const FilterState());
final equipmentFilterProvider = StateProvider.autoDispose<FilterState>((ref) => const FilterState());
final subcontractorFilterProvider = StateProvider.autoDispose<SubcontractorFilter>((ref) => const SubcontractorFilter());
