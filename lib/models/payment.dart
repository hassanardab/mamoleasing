import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final String id;
  final String eventId;
  final double amount;
  final DateTime date;
  final String method;
  final String? notes;
  final String currency;

  Payment({
    required this.id,
    required this.eventId,
    required this.amount,
    required this.date,
    required this.method,
    this.notes,
    required this.currency,
  });

  factory Payment.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Payment(
      id: doc.id,
      eventId: data['eventId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      method: data['method'] ?? '',
      notes: data['notes'],
      currency: data['currency'] ?? 'USD',
    );
  }
}
