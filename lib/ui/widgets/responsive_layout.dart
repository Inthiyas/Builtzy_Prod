import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';

class ResponsiveLayout extends ConsumerWidget {
  final String currentRoute;
  final Widget child;

  const ResponsiveLayout({
    super.key,
    required this.currentRoute,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.value;

    if (user == null) {
      return child; // E.g., Login screen
    }

    final isAdmin = user.role == UserRole.admin;

    final routes = isAdmin
        ? [
            _RouteItem(label: 'Dashboard', route: '/admin/dashboard', icon: Icons.dashboard),
            _RouteItem(label: 'Subcontractors', route: '/admin/subcontractors', icon: Icons.business),
            _RouteItem(label: 'Manpower', route: '/admin/manpower', icon: Icons.people),
            _RouteItem(label: 'Equipment', route: '/admin/equipment', icon: Icons.precision_manufacturing),
          ]
        : [
            _RouteItem(label: 'Dashboard', route: '/sub/dashboard', icon: Icons.dashboard),
            _RouteItem(label: 'My Manpower', route: '/sub/manpower', icon: Icons.people),
            _RouteItem(label: 'My Equipment', route: '/sub/equipment', icon: Icons.precision_manufacturing),
          ];

    int currentIndex = routes.indexWhere((r) => currentRoute.startsWith(r.route));
    if (currentIndex == -1) currentIndex = 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workforce & Equipment App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return Row(
              children: [
                NavigationRail(
                  extended: constraints.maxWidth > 1000,
                  selectedIndex: currentIndex,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  selectedIconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
                  selectedLabelTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                  unselectedIconTheme: IconThemeData(color: Colors.grey.shade600),
                  unselectedLabelTextStyle: TextStyle(color: Colors.grey.shade600),
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Column(
                      children: [
                        Icon(Icons.precision_manufacturing, size: constraints.maxWidth > 1000 ? 40 : 24, color: Theme.of(context).colorScheme.primary),
                        if (constraints.maxWidth > 1000) ...[
                          const SizedBox(height: 8),
                          Text('Buildzy', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        ]
                      ],
                    ),
                  ),
                  onDestinationSelected: (index) {
                    context.go(routes[index].route);
                  },
                  destinations: routes
                      .map((r) => NavigationRailDestination(
                            icon: Icon(r.icon),
                            label: Text(r.label),
                          ))
                      .toList(),
                ),
                VerticalDivider(thickness: 1, width: 1, color: Colors.grey.shade300),
                Expanded(child: child),
              ],
            );
          } else {
            return child;
          }
        },
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth <= 800) {
            return BottomNavigationBar(
              currentIndex: currentIndex,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: Colors.grey.shade600,
              type: BottomNavigationBarType.fixed,
              onTap: (index) {
                context.go(routes[index].route);
              },
              items: routes
                  .map((r) => BottomNavigationBarItem(
                        icon: Icon(r.icon),
                        label: r.label,
                      ))
                  .toList(),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _RouteItem {
  final String label;
  final String route;
  final IconData icon;

  const _RouteItem({
    required this.label,
    required this.route,
    required this.icon,
  });
}
