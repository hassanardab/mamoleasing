import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/vehicle.dart';
import '../models/client.dart';
import '../models/agreement.dart';

class CreateAgreementScreen extends StatefulWidget {
  final Vehicle vehicle;

  const CreateAgreementScreen({super.key, required this.vehicle});

  @override
  State<CreateAgreementScreen> createState() => _CreateAgreementScreenState();
}

class _CreateAgreementScreenState extends State<CreateAgreementScreen> {
  final _formKey = GlobalKey<FormState>();
  Client? _selectedClient;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  final _termsController = TextEditingController();
  final _insuranceController = TextEditingController();
  final _initialMileageController = TextEditingController();
  final _initialFuelController = TextEditingController();
  bool _isLoading = false;

  Future<void> _saveAgreement() async {
    if (_formKey.currentState!.validate() && _selectedClient != null) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        // Create agreement
        final agreement = Agreement(
          id: '', // Firestore will generate
          vehicleId: widget.vehicle.id,
          clientId: _selectedClient!.id,
          startDate: _startDate,
          endDate: _endDate,
          terms: _termsController.text,
          insuranceDetails: _insuranceController.text,
          initialMileage: double.parse(_initialMileageController.text),
          initialFuelLevel: double.parse(_initialFuelController.text),
          status: 'Active',
        );

        await FirebaseFirestore.instance.collection('agreements').add(agreement.toFirestore());

        // Update vehicle status
        await FirebaseFirestore.instance
            .collection('vehicles')
            .doc(widget.vehicle.id)
            .update({'status': 'Rented'});

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save agreement: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Agreement')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text('Vehicle: ${widget.vehicle.year} ${widget.vehicle.make} ${widget.vehicle.model}'),
                    const SizedBox(height: 16),
                    _buildClientDropdown(),
                    const SizedBox(height: 16),
                    _buildDatePickers(),
                    TextFormField(
                      controller: _initialMileageController,
                      decoration: const InputDecoration(labelText: 'Initial Mileage'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Enter mileage' : null,
                    ),
                    TextFormField(
                      controller: _initialFuelController,
                      decoration: const InputDecoration(labelText: 'Initial Fuel Level (%)'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Enter fuel level' : null,
                    ),
                    TextFormField(
                      controller: _termsController,
                      decoration: const InputDecoration(labelText: 'Agreement Terms'),
                      maxLines: 3,
                    ),
                    TextFormField(
                      controller: _insuranceController,
                      decoration: const InputDecoration(labelText: 'Insurance Policy'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveAgreement,
                      child: const Text('Save Agreement'),
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

  Widget _buildClientDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('clients').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final clients = snapshot.data!.docs.map((doc) {
          return Client.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();

        return DropdownButtonFormField<Client>(
          initialValue: _selectedClient,
          decoration: const InputDecoration(labelText: 'Client'),
          items: clients.map((client) {
            return DropdownMenuItem<Client>(
              value: client,
              child: Text(client.name),
            );
          }).toList(),
          onChanged: (client) => setState(() => _selectedClient = client),
          validator: (value) => value == null ? 'Please select a client' : null,
        );
      },
    );
  }

  Widget _buildDatePickers() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _selectDate(context, true),
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Start Date'),
              child: Text(DateFormat.yMd().format(_startDate)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: () => _selectDate(context, false),
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'End Date'),
              child: Text(DateFormat.yMd().format(_endDate)),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020), // Earlier date
      lastDate: DateTime(2030), // Future date
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }
}
