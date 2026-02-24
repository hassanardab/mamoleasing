import 'package:go_router/go_router.dart';
import './providers/app_provider.dart';
import './screens/login_screen.dart';
import './screens/vehicle_inventory_screen.dart';
import './screens/splash_screen.dart';
import './screens/add_vehicle_screen.dart';
import './screens/manage_clients_screen.dart';
import './screens/agreements_screen.dart';
import './screens/profile_screen.dart';
import './screens/bookings_screen.dart';

class AppRouter {
  final AppProvider appProvider;

  AppRouter(this.appProvider);

  late final GoRouter router = GoRouter(
    refreshListenable: appProvider,
    initialLocation: '/splash',
    routes: <RouteBase>[
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const VehicleInventoryScreen(),
        routes: [
          GoRoute(path: 'add-vehicle', builder: (context, state) => const AddVehicleScreen()),
          GoRoute(path: 'manage-clients', builder: (context, state) => const ManageClientsScreen()),
          GoRoute(path: 'agreements', builder: (context, state) => const AgreementsScreen()),
          GoRoute(path: 'profile', builder: (context, state) => const ProfileScreen()),
          GoRoute(path: 'bookings', builder: (context, state) => const BookingsScreen()),
        ],
      ),
    ],
    redirect: (context, state) {
      final isLoading = appProvider.isLoading;
      final isAuthenticated = appProvider.isAuthenticated;
      final currentPath = state.uri.path;

      // While the provider is loading initial auth/user data, keep them on splash.
      if (isLoading && currentPath != '/splash') {
        return '/splash';
      }

      // Once loading is complete:
      if (!isLoading) {
        if (!isAuthenticated && currentPath != '/login') {
          return '/login';
        }
        if (isAuthenticated && (currentPath == '/login' || currentPath == '/splash')) {
          return '/';
        }
      }

      return null;
    },
  );
}
