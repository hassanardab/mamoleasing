import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import './providers/app_provider.dart';
import './screens/auth/auth_gate.dart';
import './screens/auth/login_screen.dart';
import './screens/auth/signup_screen.dart';
import './screens/home_screen.dart';
import './screens/company/company_selection_screen.dart';
import './screens/bookings_screen.dart';

class AppRouter {
  final AppProvider appProvider;

  AppRouter(this.appProvider);

  late final GoRouter router = GoRouter(
    refreshListenable: appProvider,
    initialLocation: '/',
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (context, state) => const AuthGate(),
      ),
      GoRoute(
        path: '/:companyId/home',
        builder: (context, state) => const HomeScreen(),
      ),
       GoRoute(
        path: '/:companyId/bookings',
        builder: (context, state) => const BookingsScreen(),
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
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = appProvider.isLoggedIn;
      final isInitialized = appProvider.isInitialized;
      final companyId = appProvider.selectedModuleId;

      if (!isInitialized) return '/'; // Stay on splash while loading

      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/signup';

      if (isLoggedIn) {
        if (companyId == null || companyId.isEmpty) {
          return '/company-selection';
        }
        if (isAuthRoute || state.matchedLocation == '/company-selection') {
          return '/$companyId/home';
        }
      } else {
        if (!isAuthRoute) return '/login';
      }
      
      return null; // No redirect needed
    },
  );
}
