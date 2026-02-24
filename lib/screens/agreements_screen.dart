import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../models/agreement.dart';
import './agreement_details_screen.dart';

class AgreementsScreen extends StatelessWidget {
  const AgreementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final companyId = appProvider.selectedCompany?.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Rental Agreements')),
      body: companyId == null 
          ? const Center(child: Text("No company selected"))
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('companies')
            .doc(companyId)
            .collection('agreements')
            .orderBy('startDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No agreements found.'));
          }

          final agreements = snapshot.data!.docs.map((doc) {
            return Agreement.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

          return ListView.builder(
            itemCount: agreements.length,
            itemBuilder: (context, index) {
              final agreement = agreements[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('Agreement #${agreement.id.substring(0, 5)}...'),
                  subtitle: Text(
                      'From: ${DateFormat.yMd().format(agreement.startDate)} to ${DateFormat.yMd().format(agreement.endDate)}'),
                  trailing: Text(
                    agreement.status,
                    style: TextStyle(color: _getStatusColor(agreement.status), fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AgreementDetailsScreen(agreement: agreement),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Completed':
        return Colors.blue;
      case 'Overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
