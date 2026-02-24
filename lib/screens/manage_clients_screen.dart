import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../models/client.dart';

class ManageClientsScreen extends StatefulWidget {
  const ManageClientsScreen({super.key});

  @override
  State<ManageClientsScreen> createState() => _ManageClientsScreenState();
}

class _ManageClientsScreenState extends State<ManageClientsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _licenseController = TextEditingController();
  final _contactController = TextEditingController();
  bool _isLoading = false;

  Future<void> _addClient() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final companyId = appProvider.selectedCompany?.id;

      if (companyId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No company selected!')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      try {
        await FirebaseFirestore.instance
            .collection('companies')
            .doc(companyId)
            .collection('clients')
            .add({
          'name': _nameController.text,
          'driverLicenseId': _licenseController.text,
          'contactInfo': _contactController.text,
          'rentalHistory': [],
        });

        _nameController.clear();
        _licenseController.clear();
        _contactController.clear();

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add client: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final companyId = appProvider.selectedCompany?.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Clients')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) => value!.isEmpty ? 'Enter name' : null,
                  ),
                  TextFormField(
                    controller: _licenseController,
                    decoration: const InputDecoration(labelText: 'Driver License ID'),
                    validator: (value) => value!.isEmpty ? 'Enter license ID' : null,
                  ),
                  TextFormField(
                    controller: _contactController,
                    decoration: const InputDecoration(labelText: 'Contact Info'),
                    validator: (value) => value!.isEmpty ? 'Enter contact info' : null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _addClient,
                    child: const Text('Add Client'),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: companyId == null
                ? const Center(child: Text("No company selected"))
                : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('companies')
                  .doc(companyId)
                  .collection('clients')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No clients found.'));
                }
                final clients = snapshot.data!.docs.map((doc) {
                  return Client.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
                }).toList();

                return ListView.builder(
                  itemCount: clients.length,
                  itemBuilder: (context, index) {
                    final client = clients[index];
                    return ListTile(
                      title: Text(client.name),
                      subtitle: Text(client.driverLicenseId),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
