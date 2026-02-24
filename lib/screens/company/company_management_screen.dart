import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import 'company_form_dialog.dart';

class CompanyManagementScreen extends StatelessWidget {
  const CompanyManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Management'),
      ),
      body: appProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: appProvider.userCompanies.length,
              itemBuilder: (context, index) {
                final company = appProvider.userCompanies[index];
                return ListTile(
                  title: Text(company.name),
                  subtitle: Text(company.id),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showCompanyForm(context, company: company),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCompanyForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCompanyForm(BuildContext context, {Company? company}) {
    showDialog(
      context: context,
      builder: (context) => CompanyFormDialog(company: company),
    );
  }
}
