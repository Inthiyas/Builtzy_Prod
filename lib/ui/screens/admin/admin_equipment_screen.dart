import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';
import '../../../utils/error_handler.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/filter_bar.dart';
import '../../widgets/search_field.dart';
import '../../widgets/filter_dropdown.dart';

class AdminEquipmentScreen extends ConsumerWidget {
  const AdminEquipmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSub = ref.watch(selectedSubcontractorEquipmentProvider);

    ref.listen(equipmentProvider(selectedSub?.id), (previous, next) {
      if (next is AsyncError) {
        ErrorHandler.showErrorSnackBar(
          context,
          ErrorHandler.getErrorMessage(next.error),
        );
      }
    });
    
    if (selectedSub == null) {
      return const _SubcontractorList();
    }

    return _EquipmentList(selectedSub);
  }
}

class _SubcontractorList extends ConsumerWidget {
  const _SubcontractorList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSubs = ref.watch(subcontractorsProvider);

    return Scaffold(
      body: asyncSubs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              ErrorHandler.getErrorMessage(err),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (subs) {
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(24.0),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Equipment by Company',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final sub = subs[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(sub.companyName, style: Theme.of(context).textTheme.titleLarge),
                          subtitle: Text('Total Equipment: ${sub.totalEquipment}'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            ref.read(selectedSubcontractorEquipmentProvider.notifier).state = sub;
                          },
                        ),
                      );
                    },
                    childCount: subs.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EquipmentList extends ConsumerWidget {
  final Subcontractor subcontractor;
  const _EquipmentList(this.subcontractor);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(equipmentFilterProvider);
    final filterNotifier = ref.read(equipmentFilterProvider.notifier);
    final equipmentAsync = ref.watch(equipmentProvider(subcontractor.id));

    String formatDate(DateTime date) {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => ref.read(selectedSubcontractorEquipmentProvider.notifier).state = null,
        ),
        title: Text('${subcontractor.companyName} Equipment'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 16.0),
            child: FilterBar(
              searchField: SearchField(
                hintText: 'Search equipment...',
                initialValue: filter.search,
                onChanged: (value) => filterNotifier.state = filter.copyWith(search: value),
              ),
              filterDropdowns: [
                FilterDropdown(
                  label: 'Approval',
                  value: filter.status,
                  items: const {'all': 'All', 'approved': 'Approved', 'pending': 'Pending', 'rejected': 'Rejected'},
                  onChanged: (value) => filterNotifier.state = filter.copyWith(status: value),
                ),
                FilterDropdown(
                  label: 'Status',
                  value: filter.status2,
                  items: const {'all': 'All', 'deployed': 'Deployed', 'non_deployed': 'Non Deployed', 'under_repair': 'Under Repair'},
                  onChanged: (value) => filterNotifier.state = filter.copyWith(status2: value),
                ),
              ],
            ),
          ),
          Expanded(
            child: equipmentAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    ErrorHandler.getErrorMessage(error),
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              data: (equipmentList) {
                final sortedList = equipmentList.toList();
                if (sortedList.isEmpty) {
                  return const Center(child: Text('No equipment entries found matching filters.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: sortedList.length,

            itemBuilder: (context, index) {
              final entry = sortedList[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                entry.type,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          StatusChip.approval(entry.approvalStatus),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Date: ${formatDate(entry.date)}'),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          StatusChip.deployment(entry.deploymentStatus),
                          if (entry.approvalStatus == ApprovalStatus.pending)
                            Row(
                              children: [
                                OutlinedButton(
                                  onPressed: () => ref.read(equipmentProvider(subcontractor.id).notifier).updateApproval(entry.id, ApprovalStatus.rejected),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                  ),
                                  child: const Text('Reject'),
                                ),
                                const SizedBox(width: 8),
                                FilledButton(
                                  onPressed: () => ref.read(equipmentProvider(subcontractor.id).notifier).updateApproval(entry.id, ApprovalStatus.approved),
                                  style: FilledButton.styleFrom(backgroundColor: Colors.green),
                                  child: const Text('Approve'),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                );
              },
            );
          },
        ),
      ),
      ],
      ),
    );
  }
}

