import 'package:cloud_firestore/cloud_firestore.dart';
import 'transaction.dart';

class JournalEntry {
  final String id;
  final String description;
  final DateTime date;
  final List<TransactionModel> transactions;

  JournalEntry({
    required this.id,
    required this.description,
    required this.date,
    required this.transactions,
  });

  factory JournalEntry.fromFirestore(
      Map<String, dynamic> data, String documentId) {
    return JournalEntry(
      id: documentId,
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      transactions: (data['transactions'] as List<dynamic>? ?? [])
          .map((t) => TransactionModel.fromFirestore(t))
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'description': description,
      'date': date,
      'transactions': transactions.map((t) => t.toFirestore()).toList(),
    };
  }
}
