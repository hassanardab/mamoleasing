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

        return Scaffold(
          appBar: AppBar(
            title: Text(_getAppBarTitle(_selectedIndex, appProvider)),
            actions: [
              if (_selectedIndex == 0) _buildCompanySwitcher(context, appProvider),
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
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.directions_car_outlined),
                selectedIcon: Icon(Icons.directions_car),
                label: 'Inventory',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month),
                label: 'Bookings',
              ),
              NavigationDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: 'Clients',
              ),
            ],
          ),
          floatingActionButton: _selectedIndex == 0
              ? FloatingActionButton(
                  onPressed: () => appProvider.selectedCompany != null ? context.go('/add-vehicle') : null,
                  child: const Icon(Icons.add),
                )
              : null,
        );
      },
    );
  }

  String _getAppBarTitle(int index, AppProvider appProvider) {
    switch (index) {
      case 0:
        return appProvider.selectedCompany?.name ?? 'Vehicle Inventory';
      case 1:
        return 'Bookings';
      case 2:
        return 'Manage Clients';
      default:
        return 'Car Rental';
    }
  }

  Widget _buildDrawer(BuildContext context, AppProvider appProvider) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(appProvider.userData?.name ?? 'User'),
            accountEmail: Text(appProvider.userData?.email ?? ''),
            currentAccountPicture: const CircleAvatar(
              child: Icon(Icons.person),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Inventory'),
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Bookings'),
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Clients'),
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 2);
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
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              context.go('/profile');
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
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              Text(
                'Oops! Something went wrong.',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                appProvider.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => appProvider.signOut(),
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompanySwitcher(BuildContext context, AppProvider appProvider) {
    if (appProvider.userCompanies.length > 1) {
      return PopupMenuButton<Company>(
        icon: const Icon(Icons.business),
        onSelected: (company) => appProvider.selectCompany(company),
        itemBuilder: (context) => appProvider.userCompanies
            .map((c) => PopupMenuItem(value: c, child: Text(c.name)))
            .toList(),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildBody(BuildContext context, AppProvider appProvider, int index) {
    switch (index) {
      case 0:
        return _buildInventoryList(context, appProvider);
      case 1:
        return const Center(child: Text('Bookings Placeholder'));
      case 2:
        return const Center(child: Text('Manage Clients Placeholder'));
      default:
        return const Center(child: Text('Coming Soon'));
    }
  }

  Widget _buildInventoryList(BuildContext context, AppProvider appProvider) {
    if (appProvider.selectedCompany == null) {
      return const Center(child: Text('No company selected or found.'));
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
          return const Center(child: Text('No vehicles found for this company.'));
        }

        final vehicles = snapshot.data!.docs
            .map((doc) => Vehicle.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        return ListView.builder(
          itemCount: vehicles.length,
          itemBuilder: (context, index) => VehicleListItem(vehicle: vehicles[index]),
        );
      },
    );
  }
}
