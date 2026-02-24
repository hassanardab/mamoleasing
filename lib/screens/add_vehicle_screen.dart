import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
  XFile? _imageFile;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  Future<String?> _uploadImage(String vehicleId) async {
    if (_imageFile == null) return null;

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final companyId = appProvider.selectedCompany?.id;
    if (companyId == null) return null;

    final storageRef = FirebaseStorage.instance.ref().child(
        'companies/$companyId/vehicles/$vehicleId/images/${_imageFile!.name}');
    final uploadTask = storageRef.putFile(File(_imageFile!.path));
    final snapshot = await uploadTask.whenComplete(() => {});
    return await snapshot.ref.getDownloadURL();
  }

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
        final newVehicleRef = FirebaseFirestore.instance
            .collection('companies')
            .doc(companyId)
            .collection('vehicles')
            .doc();

        final imageUrl = await _uploadImage(newVehicleRef.id);

        await newVehicleRef.set({
          'make': _make,
          'model': _model,
          'year': _year,
          'description': _descriptionController.text,
          'status': 'Available',
          'imageUrl': imageUrl,
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
                    _imageFile == null
                        ? const Text('No image selected.')
                        : Image.file(File(_imageFile!.path), height: 200),
                    TextButton.icon(
                      icon: const Icon(Icons.image),
                      label: const Text('Select Image'),
                      onPressed: _pickImage,
                    ),
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
              color: Colors.black.withAlpha(128),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
