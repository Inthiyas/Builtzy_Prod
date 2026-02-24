import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';
import '../../../utils/error_handler.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/filter_bar.dart';
import '../../widgets/search_field.dart';
import '../../widgets/filter_dropdown.dart';

class SubEquipmentScreen extends ConsumerWidget {
  const SubEquipmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(equipmentFilterProvider);
    final filterNotifier = ref.read(equipmentFilterProvider.notifier);
    final asyncEquipment = ref.watch(equipmentProvider(null));

    ref.listen(equipmentProvider(null), (previous, next) {
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
      final typeController = TextEditingController();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Add Equipment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Equipment Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: typeController,
                decoration: const InputDecoration(labelText: 'Type/Category'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && typeController.text.isNotEmpty && authState != null) {
                  ref.read(equipmentProvider(null).notifier).addEntry(nameController.text, typeController.text);
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
      body: asyncEquipment.when(
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
        data: (equipmentList) {
          final sortedList = equipmentList.toList(); // No need to reverse since backend is DESC
          if (sortedList.isEmpty) {
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(24.0),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'My Equipment',
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
                ),
                const SliverFillRemaining(
                  child: Center(child: Text('No equipment entries found matching filters.')),
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
                    'My Equipment',
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
                              Text('Date Added: ${formatDate(entry.date)}'),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  StatusChip.deployment(entry.deploymentStatus),
                                  if (entry.approvalStatus == ApprovalStatus.approved)
                                    PopupMenuButton<DeploymentStatus>(
                                      initialValue: entry.deploymentStatus,
                                      onSelected: (status) {
                                        ref.read(equipmentProvider(null).notifier).updateDeployment(entry.id, status);
                                      },
                                      itemBuilder: (context) => const [
                                        PopupMenuItem(
                                          value: DeploymentStatus.deployed,
                                          child: Text('Mark Deployed'),
                                        ),
                                        PopupMenuItem(
                                          value: DeploymentStatus.nonDeployed,
                                          child: Text('Mark Non-Deployed'),
                                        ),
                                        PopupMenuItem(
                                          value: DeploymentStatus.underRepair,
                                          child: Text('Mark Under Repair'),
                                        ),
                                      ],
                                      child: OutlinedButton.icon(
                                        onPressed: null, // Let popup handle tap
                                        icon: const Icon(Icons.edit),
                                        label: const Text('Update Status'),
                                      ),
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
        label: const Text('Add Equipment'),
      ),
    );
  }
}
