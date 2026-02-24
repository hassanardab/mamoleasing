import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class CompanySelectionScreen extends StatelessWidget {
  const CompanySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final companies = appProvider.userCompanies;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Company'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => appProvider.signOut(),
          ),
        ],
      ),
      body: companies.isEmpty && !appProvider.isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No companies found.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Logic to add a company or join one
                    },
                    child: const Text('Create Company'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: companies.length,
              itemBuilder: (context, index) {
                final company = companies[index];
                return ListTile(
                  leading: const Icon(Icons.business),
                  title: Text(company.name),
                  subtitle: Text('${company.modulars.length} Modules'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    appProvider.selectCompany(company);
                  },
                );
              },
            ),
    );
  }
}
