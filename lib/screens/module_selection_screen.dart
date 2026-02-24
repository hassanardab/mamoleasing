import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';

class ModuleSelectionScreen extends StatelessWidget {
  const ModuleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final company = appProvider.selectedCompany;
    final modulars = company?.modulars ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(company?.name ?? 'Select Module'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => context.go('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => appProvider.signOut(),
          ),
        ],
      ),
      body: modulars.isEmpty
          ? _buildNoModulesBody(context, appProvider)
          : _buildModuleList(context, appProvider, modulars),
    );
  }

  Widget _buildNoModulesBody(BuildContext context, AppProvider appProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.apps_outage, size: 80, color: Colors.grey),
          const SizedBox(height: 24),
          const Text('No Modules Available', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text('This company doesn\'t have any enabled modulars.', textAlign: TextAlign.center),
          const SizedBox(height: 32),
          if (appProvider.userCompanies.length > 1)
            ElevatedButton(
              onPressed: () {
                _showCompanySwitcher(context, appProvider);
              },
              child: const Text('Switch Company'),
            ),
        ],
      ),
    );
  }

  Widget _buildModuleList(BuildContext context, AppProvider appProvider, List<String> modulars) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: modulars.length,
      itemBuilder: (context, index) {
        final moduleId = modulars[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: _getModuleIcon(moduleId),
            title: Text(
              _getModuleTitle(moduleId),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(_getModuleDescription(moduleId)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              appProvider.selectModule(moduleId);
              context.go('/');
            },
          ),
        );
      },
    );
  }

  void _showCompanySwitcher(BuildContext context, AppProvider appProvider) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: appProvider.userCompanies.map((c) {
            return ListTile(
              title: Text(c.name),
              onTap: () {
                appProvider.selectCompany(c);
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  Icon _getModuleIcon(String moduleId) {
    switch (moduleId) {
      case 'car_rental':
        return const Icon(Icons.directions_car, size: 40, color: Colors.blue);
      case 'booking':
        return const Icon(Icons.calendar_month, size: 40, color: Colors.orange);
      case 'tasks':
        return const Icon(Icons.task_alt, size: 40, color: Colors.green);
      default:
        return const Icon(Icons.extension, size: 40, color: Colors.grey);
    }
  }

  String _getModuleTitle(String moduleId) {
    switch (moduleId) {
      case 'car_rental':
        return 'Car Rental';
      case 'booking':
        return 'Booking System';
      case 'tasks':
        return 'Tasks Manager';
      default:
        return moduleId.toUpperCase();
    }
  }

  String _getModuleDescription(String moduleId) {
    switch (moduleId) {
      case 'car_rental':
        return 'Fleet management, rentals, and agreements.';
      case 'booking':
        return 'Appointments, schedules, and reservations.';
      case 'tasks':
        return 'Manage team tasks and operations.';
      default:
        return 'Access module features.';
    }
  }
}
