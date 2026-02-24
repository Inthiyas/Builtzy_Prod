import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';
import '../../../utils/error_handler.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/filter_bar.dart';
import '../../widgets/search_field.dart';
import '../../widgets/filter_dropdown.dart';

class SubManpowerScreen extends ConsumerWidget {
  const SubManpowerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(manpowerFilterProvider);
    final filterNotifier = ref.read(manpowerFilterProvider.notifier);
    final asyncManpower = ref.watch(manpowerProvider(null));

    ref.listen(manpowerProvider(null), (previous, next) {
      if (next is AsyncError) {
        ErrorHandler.showErrorSnackBar(
          context,
          ErrorHandler.getErrorMessage(next.error),
        );
      }
    });
    final authState = ref.watch(authProvider).value;

    String formatDate(DateTime date) {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }

    void showAddDialog() {
      final nameController = TextEditingController();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Add Manpower'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name / Designation'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && authState != null) {
                  ref.read(manpowerProvider(null).notifier).addEntry(nameController.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: asyncManpower.when(
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
        data: (manpowerList) {
          final sortedList = manpowerList.toList(); // No need to reverse since backend is DESC
          if (sortedList.isEmpty) {
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(24.0),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'My Manpower',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 16.0),
                  sliver: SliverToBoxAdapter(
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
                ),
                const SliverFillRemaining(
                  child: Center(child: Text('No manpower entries found matching filters.')),
                ),
              ],
            );
          }

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(24.0),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'My Manpower',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 16.0),
                sliver: SliverToBoxAdapter(
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
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
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
                              Text('Date Added: ${formatDate(entry.date)}'),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  StatusChip.attendance(entry.attendanceStatus),
                                  if (entry.approvalStatus == ApprovalStatus.approved)
                                    SegmentedButton<AttendanceStatus>(
                                      segments: const [
                                        ButtonSegment(
                                          value: AttendanceStatus.present,
                                          label: Text('Present'),
                                          icon: Icon(Icons.check),
                                        ),
                                        ButtonSegment(
                                          value: AttendanceStatus.absent,
                                          label: Text('Absent'),
                                          icon: Icon(Icons.close),
                                        ),
                                      ],
                                      selected: {entry.attendanceStatus},
                                      onSelectionChanged: (Set<AttendanceStatus> newSelection) {
                                        ref.read(manpowerProvider(null).notifier).updateAttendance(entry.id, newSelection.first);
                                      },
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: sortedList.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Manpower'),
      ),
    );
  }
}
