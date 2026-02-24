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
import './screens/module_selection_screen.dart';

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
        path: '/select-module',
        builder: (context, state) => const ModuleSelectionScreen(),
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
      final selectedModuleId = appProvider.selectedModuleId;
      final currentPath = state.uri.path;

      if (isLoading && currentPath != '/splash') {
        return '/splash';
      }

      if (!isLoading) {
        if (!isAuthenticated && currentPath != '/login') {
          return '/login';
        }
        
        if (isAuthenticated) {
          // If no module is selected, redirect to selection screen
          if ((selectedModuleId == null || selectedModuleId.isEmpty) && currentPath != '/select-module') {
            return '/select-module';
          }
          
          // If a module is selected and we're on login/splash/select-module, go to main
          if (selectedModuleId != null && selectedModuleId.isNotEmpty && 
              (currentPath == '/login' || currentPath == '/splash' || currentPath == '/select-module')) {
            return '/';
          }
        }
      }

      return null;
    },
  );
}
