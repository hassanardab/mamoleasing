import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class NoAccessScreen extends StatelessWidget {
  const NoAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Access Denied'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => appProvider.signOut(),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.block, size: 80, color: Colors.red),
              const SizedBox(height: 24),
              Text(
                'No Car Rental Access',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              const Text(
                'Your account or selected company does not have the Car Rental module enabled. Please contact support if you believe this is an error.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              if (appProvider.userCompanies.length > 1)
                Column(
                  children: [
                    const Text('Try switching to another company:'),
                    const SizedBox(height: 16),
                    DropdownButton<Company>(
                      value: appProvider.selectedCompany,
                      onChanged: (Company? company) {
                        if (company != null) {
                          appProvider.selectCompany(company);
                        }
                      },
                      items: appProvider.userCompanies.map((Company company) {
                        return DropdownMenuItem<Company>(
                          value: company,
                          child: Text(company.name),
                        );
                      }).toList(),
                    ),
                  ],
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
}
