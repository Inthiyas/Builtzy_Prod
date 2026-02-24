import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/providers.dart';
import '../../widgets/metric_card.dart';
import '../../../utils/error_handler.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(dashboardMetricsProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: metrics.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                ErrorHandler.getErrorMessage(error),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (data) {
            if (data == null) return const Center(child: Text('No data'));
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Dashboard',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Manpower Metrics',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 800 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 2.5,
                      children: [
                        MetricCard(
                          title: 'Total Manpower',
                          value: '${data.totalManpower}',
                          icon: Icons.people,
                          color: Colors.blue,
                        ),
                        MetricCard(
                          title: 'Present',
                          value: '${data.presentManpower}',
                          icon: Icons.check_circle,
                          color: Colors.green,
                        ),
                        MetricCard(
                          title: 'Absent',
                          value: '${data.absentManpower}',
                          icon: Icons.cancel,
                          color: Colors.red,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),
                Text(
                  'Equipment Metrics',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 800 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 2.5,
                      children: [
                        MetricCard(
                          title: 'Total Equipment',
                          value: '${data.totalEquipment}',
                          icon: Icons.precision_manufacturing,
                          color: Colors.deepPurple,
                        ),
                        MetricCard(
                          title: 'Deployed',
                          value: '${data.deployedEquipment}',
                          icon: Icons.play_circle_filled,
                          color: Colors.teal,
                        ),
                        MetricCard(
                          title: 'Under Repair',
                          value: '${data.underRepairEquipment}',
                          icon: Icons.handyman,
                          color: Colors.orange,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subcontractors Overview',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton(
                      onPressed: () => context.go('/admin/subcontractors'),
                      child: const Text('Manage All'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ref.watch(subcontractorsProvider).when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Text(
                        ErrorHandler.getErrorMessage(err),
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                      data: (subs) {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: subs.take(5).length,
                          itemBuilder: (context, index) {
                            final sub = subs[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                  child: Text(sub.companyName[0]),
                                ),
                                title: Text(sub.companyName),
                                subtitle: Text('${sub.totalManpower} Workers | ${sub.totalEquipment} Equipment'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  ref.read(selectedSubcontractorManpowerProvider.notifier).state = sub;
                                  context.go('/admin/manpower');
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
              ],
            );
          },
        ),
      ),
    );
  }
}
