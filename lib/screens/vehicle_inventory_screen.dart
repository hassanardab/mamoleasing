import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_provider.dart';
import '../models/vehicle.dart';
import '../widgets/vehicle_list_item.dart';

class VehicleInventoryScreen extends StatefulWidget {
  const VehicleInventoryScreen({super.key});

  @override
  State<VehicleInventoryScreen> createState() => _VehicleInventoryScreenState();
}

class _VehicleInventoryScreenState extends State<VehicleInventoryScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        if (appProvider.errorMessage != null) {
          return _buildErrorBody(context, appProvider);
        }

        final moduleId = appProvider.selectedModuleId;

        return Scaffold(
          appBar: AppBar(
            title: Text(_getAppBarTitle(_selectedIndex, appProvider)),
            actions: [
              IconButton(
                icon: const Icon(Icons.apps),
                tooltip: 'Switch Module',
                onPressed: () {
                  appProvider
                      .selectModule(''); // Logic to trigger redirect in router
                },
              ),
              IconButton(
                icon: const Icon(Icons.account_circle),
                tooltip: 'Profile',
                onPressed: () => context.go('/profile'),
              ),
            ],
          ),
          drawer: _buildDrawer(context, appProvider),
          body: _buildBody(context, appProvider, _selectedIndex),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: _getNavDestinations(moduleId),
          ),
          floatingActionButton: _shouldShowFAB(_selectedIndex, moduleId)
              ? FloatingActionButton(
                  onPressed: () =>
                      _handleFABAction(context, _selectedIndex, moduleId),
                  child: const Icon(Icons.add),
                )
              : null,
        );
      },
    );
  }

  List<NavigationDestination> _getNavDestinations(String? moduleId) {
    if (moduleId == 'booking') {
      return const [
        NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined),
          selectedIcon: Icon(Icons.calendar_month),
          label: 'Schedule',
        ),
        NavigationDestination(
          icon: Icon(Icons.list_alt_outlined),
          selectedIcon: Icon(Icons.list_alt),
          label: 'Bookings',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_outline),
          selectedIcon: Icon(Icons.people),
          label: 'Clients',
        ),
      ];
    }
    // Default to car_rental
    return const [
      NavigationDestination(
        icon: Icon(Icons.directions_car_outlined),
        selectedIcon: Icon(Icons.directions_car),
        label: 'Inventory',
      ),
      NavigationDestination(
        icon: Icon(Icons.calendar_today_outlined),
        selectedIcon: Icon(Icons.calendar_today),
        label: 'Rentals',
      ),
      NavigationDestination(
        icon: Icon(Icons.people_outline),
        selectedIcon: Icon(Icons.people),
        label: 'Clients',
      ),
    ];
  }

  bool _shouldShowFAB(int index, String? moduleId) {
    if (moduleId == 'booking') {
      return index == 1; // Show for bookings list
    }
    return index == 0; // Show for car inventory
  }

  void _handleFABAction(BuildContext context, int index, String? moduleId) {
    if (moduleId == 'booking') {
      // Future: Navigate to create booking
    } else {
      context.go('/add-vehicle');
    }
  }

  String _getAppBarTitle(int index, AppProvider appProvider) {
    final moduleId = appProvider.selectedModuleId;
    if (moduleId == 'booking') {
      switch (index) {
        case 0:
          return 'Schedule';
        case 1:
          return 'All Bookings';
        case 2:
          return 'Clients';
        default:
          return 'Booking System';
      }
    }
    switch (index) {
      case 0:
        return appProvider.selectedCompany?.name ?? 'Inventory';
      case 1:
        return 'Active Rentals';
      case 2:
        return 'Client Management';
      default:
        return 'Car Rental';
    }
  }

  Widget _buildDrawer(BuildContext context, AppProvider appProvider) {
    final moduleId = appProvider.selectedModuleId;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(appProvider.userData?.name ?? 'User'),
            accountEmail: Text(appProvider.userData?.email ?? ''),
            currentAccountPicture:
                const CircleAvatar(child: Icon(Icons.person)),
          ),
          if (moduleId == 'booking') ...[
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('My Schedule'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedIndex = 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.book_online),
              title: const Text('Manage Bookings'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedIndex = 1);
              },
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text('Car Inventory'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedIndex = 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.article),
              title: const Text('Rental Agreements'),
              onTap: () {
                Navigator.pop(context);
                context.go('/agreements');
              },
            ),
          ],
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Clients'),
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 2);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.apps),
            title: const Text('Switch Module'),
            onTap: () {
              Navigator.pop(context);
              appProvider.selectModule('');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => appProvider.signOut(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBody(BuildContext context, AppProvider appProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text('Oops! Something went wrong.',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(appProvider.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton(
                onPressed: () => appProvider.signOut(),
                child: const Text('Sign Out')),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppProvider appProvider, int index) {
    final moduleId = appProvider.selectedModuleId;

    if (moduleId == 'booking') {
      switch (index) {
        case 0:
          return const Center(child: Text('Calendar/Schedule View'));
        case 1:
          return const Center(child: Text('List of All Bookings'));
        case 2:
          return const Center(child: Text('Clients List'));
        default:
          return const Center(child: Text('Module Error'));
      }
    }

    // Car Rental Logic
    switch (index) {
      case 0:
        return _buildInventoryList(context, appProvider);
      case 1:
        return const Center(child: Text('Active Agreements List'));
      case 2:
        return const Center(child: Text('Clients List'));
      default:
        return const Center(child: Text('Module Error'));
    }
  }

  Widget _buildInventoryList(BuildContext context, AppProvider appProvider) {
    if (appProvider.selectedCompany == null) {
      return const Center(child: Text('No company selected.'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('companies')
          .doc(appProvider.selectedCompany!.id)
          .collection('vehicles')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No vehicles found.'));
        }

        final vehicles = snapshot.data!.docs
            .map((doc) => Vehicle.fromFirestore(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        return ListView.builder(
          itemCount: vehicles.length,
          itemBuilder: (context, index) =>
              VehicleListItem(vehicle: vehicles[index]),
        );
      },
    );
  }
}
