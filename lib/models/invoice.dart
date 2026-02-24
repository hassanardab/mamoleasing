import 'package:cloud_firestore/cloud_firestore.dart';

class Invoice {
  final String id;
  final String agreementId;
  final String clientId;
  final DateTime issueDate;
  final DateTime dueDate;
  final List<Map<String, dynamic>> lineItems;
  final double totalAmount;
  final String status;

  Invoice({
    required this.id,
    required this.agreementId,
    required this.clientId,
    required this.issueDate,
    required this.dueDate,
    required this.lineItems,
    required this.totalAmount,
    required this.status,
  });

  factory Invoice.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Invoice(
      id: documentId,
      agreementId: data['agreementId'] ?? '',
      clientId: data['clientId'] ?? '',
      issueDate: (data['issueDate'] as Timestamp).toDate(),
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      lineItems: List<Map<String, dynamic>>.from(data['lineItems'] ?? []),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      status: data['status'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'agreementId': agreementId,
      'clientId': clientId,
      'issueDate': issueDate,
      'dueDate': dueDate,
      'lineItems': lineItems,
      'totalAmount': totalAmount,
      'status': status,
    };
  }
}
