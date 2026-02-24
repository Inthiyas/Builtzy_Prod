import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/providers.dart';
import '../../widgets/metric_card.dart';

class SubDashboardScreen extends ConsumerWidget {
  const SubDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(dashboardMetricsProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: metrics.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
          data: (data) {
            if (data == null) return const Center(child: Text('No data'));
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Dashboard',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),
                Text(
                  'My Manpower',
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
                  'My Equipment',
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
              ],
            );
          },
        ),
      ),
    );
  }
}
