import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';
import '../../../utils/error_handler.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/filter_bar.dart';
import '../../widgets/search_field.dart';
import '../../widgets/filter_dropdown.dart';

class AdminManpowerScreen extends ConsumerWidget {
  const AdminManpowerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSub = ref.watch(selectedSubcontractorManpowerProvider);
    
    // Listen for errors from the manpowerProvider and show a SnackBar
    // Even if we are just showing the subcontractor list, listening here ensures
    // global error propagation for the family provider members.
    ref.listen(manpowerProvider(selectedSub?.id), (previous, next) {
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

    return _ManpowerList(selectedSub);
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
                    'Manpower by Company',
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
                          subtitle: Text('Total Manpower: ${sub.totalManpower}'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            ref.read(selectedSubcontractorManpowerProvider.notifier).state = sub;
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

class _ManpowerList extends ConsumerWidget {
  final Subcontractor subcontractor;
  const _ManpowerList(this.subcontractor);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(manpowerFilterProvider);
    final filterNotifier = ref.read(manpowerFilterProvider.notifier);
    final manpowerAsync = ref.watch(manpowerProvider(subcontractor.id));

    String formatDate(DateTime date) {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => ref.read(selectedSubcontractorManpowerProvider.notifier).state = null,
        ),
        title: Text('${subcontractor.companyName} Manpower'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 16.0),
            child: FilterBar(
              searchField: SearchField(
                hintText: 'Search manpower...',
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
                  label: 'Attendance',
                  value: filter.status2,
                  items: const {'all': 'All', 'present': 'Present', 'absent': 'Absent', 'not_marked': 'Not Marked'},
                  onChanged: (value) => filterNotifier.state = filter.copyWith(status2: value),
                ),
              ],
            ),
          ),
          Expanded(
            child: manpowerAsync.when(
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
              data: (manpowerList) {
                final sortedList = manpowerList.toList(); // No need to reverse since backend is DESC
                if (sortedList.isEmpty) {
                  return const Center(child: Text('No manpower entries found matching filters.'));
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
                          Text(
                            entry.name,
                            style: Theme.of(context).textTheme.titleLarge,
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
                          StatusChip.attendance(entry.attendanceStatus),
                          if (entry.approvalStatus == ApprovalStatus.pending)
                            Row(
                              children: [
                                OutlinedButton(
                                  onPressed: () => ref.read(manpowerProvider(subcontractor.id).notifier).updateApproval(entry.id, ApprovalStatus.rejected),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                  ),
                                  child: const Text('Reject'),
                                ),
                                const SizedBox(width: 8),
                                FilledButton(
                                  onPressed: () => ref.read(manpowerProvider(subcontractor.id).notifier).updateApproval(entry.id, ApprovalStatus.approved),
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

