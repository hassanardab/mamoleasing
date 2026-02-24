import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import './providers/app_provider.dart';
import './screens/auth/login_screen.dart';
import './screens/auth/signup_screen.dart';
import './screens/home_screen.dart';
import './screens/company/company_selection_screen.dart';
import './screens/module_selection_screen.dart';
import './screens/bookings_screen.dart';
import './screens/profile_screen.dart';

class AppRouter {
  final AppProvider appProvider;

  AppRouter(this.appProvider);

  late final GoRouter router = GoRouter(
    refreshListenable: appProvider,
    initialLocation: '/',
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/company-selection',
        builder: (context, state) => const CompanySelectionScreen(),
      ),
      GoRoute(
        path: '/module-selection',
        builder: (context, state) => const ModuleSelectionScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/:companyId/:moduleId/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/:companyId/:moduleId/bookings',
        builder: (context, state) => const BookingsScreen(),
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = appProvider.isLoggedIn;
      final isInitialized = appProvider.isInitialized;
      final selectedCompany = appProvider.selectedCompany;
      final selectedModule = appProvider.selectedModuleId;

      if (!isInitialized) return null; // Stay where we are until initialized

      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      if (!isLoggedIn) {
        return isAuthRoute ? null : '/login';
      }

      // User is logged in
      if (isAuthRoute) return '/company-selection';

      if (selectedCompany == null) {
        return state.matchedLocation == '/company-selection'
            ? null
            : '/company-selection';
      }

      if (selectedModule == null) {
        return state.matchedLocation == '/module-selection'
            ? null
            : '/module-selection';
      }

      // Both company and module selected
      if (state.matchedLocation == '/' ||
          state.matchedLocation == '/company-selection' ||
          state.matchedLocation == '/module-selection') {
        return '/${selectedCompany.id}/$selectedModule/home';
      }

      return null; // No redirect needed
    },
  );
}
