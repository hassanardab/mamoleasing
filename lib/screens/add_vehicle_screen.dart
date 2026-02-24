import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  String _make = '';
  String _model = '';
  int _year = 0;
  bool _isLoading = false;
  final _descriptionController = TextEditingController();

  Future<void> _saveVehicle() async {
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
            .collection('vehicles')
            .add({
          'make': _make,
          'model': _model,
          'year': _year,
          'description': _descriptionController.text,
          'status': 'Available',
          'preRentalImages': [],
        });

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save vehicle: $e')),
        );
      }
    }
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Vehicle')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Make'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the make';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _make = value!;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Model'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the model';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _model = value!;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Year'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a valid year';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid year';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _year = int.parse(value!);
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      maxLines: 5,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveVehicle,
                      child: const Text('Save Vehicle'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
