import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/models.dart';
import '../../../providers/subcontractor_provider.dart';
import '../../../utils/error_handler.dart';
import '../../widgets/filter_bar.dart';
import '../../widgets/search_field.dart';
import '../../widgets/filter_dropdown.dart';
import '../../../providers/filter_providers.dart';

class SubcontractorManagementScreen extends ConsumerWidget {
  const SubcontractorManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(subcontractorFilterProvider);
    final filterNotifier = ref.read(subcontractorFilterProvider.notifier);
    final asyncSubcontractors = ref.watch(subcontractorsProvider);

    ref.listen(subcontractorsProvider, (previous, next) {
      if (next is AsyncError) {
        ErrorHandler.showErrorSnackBar(
          context,
          ErrorHandler.getErrorMessage(next.error),
        );
      }
    });

    void showAddDialog() {
      final usernameCtrl = TextEditingController();
      final passwordCtrl = TextEditingController();
      final companyNameCtrl = TextEditingController();
      final contactPersonCtrl = TextEditingController();
      final phoneNumberCtrl = TextEditingController();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Add Subcontractor'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: usernameCtrl, decoration: const InputDecoration(labelText: 'Username')),
                const SizedBox(height: 8),
                TextField(controller: passwordCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
                const SizedBox(height: 8),
                TextField(controller: companyNameCtrl, decoration: const InputDecoration(labelText: 'Company Name')),
                const SizedBox(height: 8),
                TextField(controller: contactPersonCtrl, decoration: const InputDecoration(labelText: 'Contact Person')),
                const SizedBox(height: 8),
                TextField(controller: phoneNumberCtrl, decoration: const InputDecoration(labelText: 'Phone Number')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (usernameCtrl.text.isNotEmpty && passwordCtrl.text.isNotEmpty && companyNameCtrl.text.isNotEmpty) {
                  ref.read(subcontractorsProvider.notifier).createSubcontractor(
                        username: usernameCtrl.text,
                        password: passwordCtrl.text,
                        companyName: companyNameCtrl.text,
                        contactPerson: contactPersonCtrl.text,
                        phoneNumber: phoneNumberCtrl.text,
                      );
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      );
    }

    void showEditDialog(Subcontractor sub) {
      final companyNameCtrl = TextEditingController(text: sub.companyName);
      final contactPersonCtrl = TextEditingController(text: sub.contactPerson);
      final phoneNumberCtrl = TextEditingController(text: sub.phoneNumber);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Edit Subcontractor'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: companyNameCtrl, decoration: const InputDecoration(labelText: 'Company Name')),
                const SizedBox(height: 8),
                TextField(controller: contactPersonCtrl, decoration: const InputDecoration(labelText: 'Contact Person')),
                const SizedBox(height: 8),
                TextField(controller: phoneNumberCtrl, decoration: const InputDecoration(labelText: 'Phone Number')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (companyNameCtrl.text.isNotEmpty) {
                  ref.read(subcontractorsProvider.notifier).updateSubcontractor(
                        sub.id,
                        companyName: companyNameCtrl.text,
                        contactPerson: contactPersonCtrl.text,
                        phoneNumber: phoneNumberCtrl.text,
                      );
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    }

    void showDeleteDialog(Subcontractor sub) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete ${sub.companyName}? This action is permanent and deletes all associated records.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
              onPressed: () {
                ref.read(subcontractorsProvider.notifier).deleteSubcontractor(sub.id);
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: asyncSubcontractors.when(
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
        data: (subcontractors) {
          if (subcontractors.isEmpty) {
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(24.0),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Manage Subcontractors',
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
                        hintText: 'Search subcontractors...',
                        initialValue: filter.search,
                        onChanged: (value) => filterNotifier.state = filter.copyWith(search: value),
                      ),
                      filterDropdowns: [
                        FilterDropdown(
                          label: 'Manpower Count',
                          value: filter.manpowerRange,
                          items: const {'all': 'All', '0-10': '0-10', '11-50': '11-50', '51+': '51+'},
                          onChanged: (value) => filterNotifier.state = filter.copyWith(manpowerRange: value!),
                        ),
                        FilterDropdown(
                          label: 'Equipment Count',
                          value: filter.equipmentRange,
                          items: const {'all': 'All', '0-10': '0-10', '11-50': '11-50', '51+': '51+'},
                          onChanged: (value) => filterNotifier.state = filter.copyWith(equipmentRange: value!),
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverFillRemaining(
                  child: Center(child: Text('No subcontractors found matching filters.')),
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
                    'Manage Subcontractors',
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
                      hintText: 'Search subcontractors...',
                      initialValue: filter.search,
                      onChanged: (value) => filterNotifier.state = filter.copyWith(search: value),
                    ),
                    filterDropdowns: [
                      FilterDropdown(
                        label: 'Manpower Count',
                        value: filter.manpowerRange,
                        items: const {'all': 'All', '0-10': '0-10', '11-50': '11-50', '51+': '51+'},
                        onChanged: (value) => filterNotifier.state = filter.copyWith(manpowerRange: value!),
                      ),
                      FilterDropdown(
                        label: 'Equipment Count',
                        value: filter.equipmentRange,
                        items: const {'all': 'All', '0-10': '0-10', '11-50': '11-50', '51+': '51+'},
                        onChanged: (value) => filterNotifier.state = filter.copyWith(equipmentRange: value!),
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
                      final sub = subcontractors[index];
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
                                  Expanded(
                                    child: Text(
                                      sub.companyName,
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => showEditDialog(sub),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => showDeleteDialog(sub),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Contact: ${sub.contactPerson.isNotEmpty ? sub.contactPerson : "N/A"}'),
                              Text('Phone: ${sub.phoneNumber.isNotEmpty ? sub.phoneNumber : "N/A"}'),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        ref.read(selectedSubcontractorManpowerProvider.notifier).state = sub;
                                        context.go('/admin/manpower');
                                      },
                                      icon: const Icon(Icons.people),
                                      label: const Text('View Manpower'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        ref.read(selectedSubcontractorEquipmentProvider.notifier).state = sub;
                                        context.go('/admin/equipment');
                                      },
                                      icon: const Icon(Icons.precision_manufacturing),
                                      label: const Text('View Equipment'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: subcontractors.length,
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
        label: const Text('Add Subcontractor'),
      ),
    );
  }
}
