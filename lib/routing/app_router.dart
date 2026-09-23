import 'go_router_refresh_stream.dart';

import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../features/auth/presentation/screens/login_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/animals/presentation/screens/animal_list_screen.dart';
import '../features/milk/presentation/screens/milk_entry_screen.dart';
import '../features/expenses/presentation/screens/expense_entry_screen.dart';
import '../features/inventory/presentation/screens/inventory_screen.dart';
import '../features/health/presentation/screens/health_screen.dart';
import '../features/pregnancy/presentation/screens/pregnancy_screen.dart';
import '../features/reports/presentation/screens/reports_screen.dart';
import '../features/audit_log/presentation/screens/audit_log_screen.dart';

import 'routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',

  refreshListenable: GoRouterRefreshStream(
    FirebaseAuth.instance.authStateChanges(),
  ),

  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final isLoggedIn = user != null;
    final isLoginPage = state.matchedLocation == '/login';

    if (!isLoggedIn && !isLoginPage) {
      return '/login';
    }

    if (isLoggedIn && isLoginPage) {
      return '/';
    }

    return null;
  },

  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    GoRoute(
      path: AppRoutes.dashboard,
      builder: (context, state) => const DashboardScreen(),
    ),

    GoRoute(
      path: AppRoutes.animalList,
      builder: (context, state) => const AnimalListScreen(),
    ),

    GoRoute(
      path: AppRoutes.milkEntry,
      builder: (context, state) => const MilkEntryScreen(),
    ),

    GoRoute(
      path: AppRoutes.expenseEntry,
      builder: (context, state) => const ExpenseEntryScreen(),
    ),

    GoRoute(
      path: AppRoutes.inventory,
      builder: (context, state) => const InventoryScreen(),
    ),

    GoRoute(
      path: AppRoutes.health,
      builder: (context, state) => const HealthScreen(),
    ),

    GoRoute(
      path: AppRoutes.pregnancy,
      builder: (context, state) => const PregnancyScreen(),
    ),

    GoRoute(
      path: AppRoutes.reports,
      builder: (context, state) => const ReportsScreen(),
    ),

    // ==========================================================
    // AUDIT LOG
    // ==========================================================

    GoRoute(
      path: AppRoutes.auditLog,
      builder: (context, state) => const AuditLogScreen(),
    ),
  ],
);