import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../providers/providers.dart';

import '../ui/screens/login_screen.dart';
import '../ui/widgets/responsive_layout.dart';
import '../ui/screens/admin/admin_dashboard_screen.dart';
import '../ui/screens/admin/admin_manpower_screen.dart';
import '../ui/screens/admin/admin_equipment_screen.dart';
import '../ui/screens/sub/sub_dashboard_screen.dart';
import '../ui/screens/sub/sub_manpower_screen.dart';
import '../ui/screens/sub/sub_equipment_screen.dart';
import '../ui/screens/admin/subcontractor_management_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      if (authState.isLoading) return '/splash';

      final isLoggingIn = state.matchedLocation == '/login';
      final isSplash = state.matchedLocation == '/splash';
      final user = authState.value;

      if (user == null) {
        return isLoggingIn ? null : '/login';
      }

      final isAdmin = user.role == UserRole.admin;

      if (isLoggingIn || isSplash) {
        return isAdmin ? '/admin/dashboard' : '/sub/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return ResponsiveLayout(
            currentRoute: state.matchedLocation,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/admin/dashboard',
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: '/admin/subcontractors',
            builder: (context, state) => const SubcontractorManagementScreen(),
          ),
          GoRoute(
            path: '/admin/manpower',
            builder: (context, state) => const AdminManpowerScreen(),
          ),
          GoRoute(
            path: '/admin/equipment',
            builder: (context, state) => const AdminEquipmentScreen(),
          ),
          GoRoute(
            path: '/sub/dashboard',
            builder: (context, state) => const SubDashboardScreen(),
          ),
          GoRoute(
            path: '/sub/manpower',
            builder: (context, state) => const SubManpowerScreen(),
          ),
          GoRoute(
            path: '/sub/equipment',
            builder: (context, state) => const SubEquipmentScreen(),
          ),
        ],
      ),
    ],
  );
});
