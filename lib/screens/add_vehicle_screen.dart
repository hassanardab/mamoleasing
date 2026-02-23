import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';
import '../models/vehicle.dart';

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

  Future<void> _generateDescription() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      try {
        //     final model = FirebaseAI.instance.backend(GenerativeBackend.googleAI())
        // .generativeModel(model: 'gemini-2.5-flash-lite');
        //     final prompt =
        //         'Write a short, engaging description for a rental listing of a $_year $_make $_model.';

        //     final response = await model.generateContent([Content.text(prompt)]);

        setState(() {
          // _descriptionController.text = response.text ?? 'Error generating description.';
        });
      } catch (e) {
        // Handle error
        setState(() {
          _descriptionController.text = 'Error: ${e.toString()}';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _saveVehicle() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newVehicle = Vehicle(
        id: DateTime.now().toString(), // Simple unique ID
        make: _make,
        model: _model,
        year: _year,
        description: _descriptionController.text,
      );
      Navigator.pop(context, newVehicle);
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
                    ElevatedButton(
                      onPressed: _isLoading ? null : _generateDescription,
                      child: const Text('Generate Description (AI)'),
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
                      onPressed: _saveVehicle,
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
