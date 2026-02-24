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
      appBar: AppBar(title: const Text('Select a Company')),
      body: ListView.builder(
        itemCount: companies.length,
        itemBuilder: (context, index) {
          final company = companies[index];
          return ListTile(
            title: Text(company.name),
            onTap: () {
              appProvider.setSelectedModuleId(company.id);
            },
          );
        },
      ),
    );
  }
}
