import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/agreement.dart';
import '../models/client.dart';
import '../models/vehicle.dart';

class AgreementDetailsScreen extends StatefulWidget {
  final Agreement agreement;

  const AgreementDetailsScreen({super.key, required this.agreement});

  @override
  State<AgreementDetailsScreen> createState() => _AgreementDetailsScreenState();
}

class _AgreementDetailsScreenState extends State<AgreementDetailsScreen> {
  late Future<Map<String, dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _fetchData();
  }

  Future<Map<String, dynamic>> _fetchData() async {
    final vehicleDoc = await FirebaseFirestore.instance
        .collection('vehicles')
        .doc(widget.agreement.vehicleId)
        .get();
    final clientDoc = await FirebaseFirestore.instance
        .collection('clients')
        .doc(widget.agreement.clientId)
        .get();

    return {
      'vehicle': Vehicle.fromFirestore(
          vehicleDoc.data() as Map<String, dynamic>, vehicleDoc.id),
      'client': Client.fromFirestore(
          clientDoc),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text('Agreement #${widget.agreement.id.substring(0, 5)}...')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Data not found.'));
          }

          final Vehicle vehicle = snapshot.data!['vehicle'];
          final Client client = snapshot.data!['client'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Vehicle Details'),
                  _buildDetailItem('Make', vehicle.make),
                  _buildDetailItem('Model', vehicle.model),
                  _buildDetailItem('Year', vehicle.year.toString()),
                  const Divider(height: 30),
                  _buildSectionTitle('Client Details'),
                  _buildDetailItem('Name', client.name),
                  _buildDetailItem(
                      'License ID', client.driverLicenseId ?? 'N/A'),
                  _buildDetailItem('Contact', client.contactInfo ?? 'N/A'),
                  const Divider(height: 30),
                  _buildSectionTitle('Agreement Details'),
                  _buildDetailItem('Status', widget.agreement.status),
                  _buildDetailItem('Start Date',
                      DateFormat.yMd().format(widget.agreement.startDate)),
                  _buildDetailItem('End Date',
                      DateFormat.yMd().format(widget.agreement.endDate)),
                  _buildDetailItem('Terms', widget.agreement.terms),
                  _buildDetailItem(
                      'Insurance', widget.agreement.insuranceDetails),
                  _buildDetailItem('Initial Mileage',
                      widget.agreement.initialMileage.toString()),
                  _buildDetailItem('Initial Fuel',
                      '${widget.agreement.initialFuelLevel}%'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: Theme.of(context).textTheme.headlineSmall);
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
