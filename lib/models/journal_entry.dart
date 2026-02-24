import 'package:cloud_firestore/cloud_firestore.dart';
import 'transaction.dart';

class JournalEntry {
  final String id;
  final String companyId;
  final String description;
  final DateTime date;
  final List<TransactionModel> transactions;
  final String source; // 'booking', 'expense', etc.
  final String? referenceId;
  final String? currency;
  final Map<String, dynamic>? metadata;

  JournalEntry({
    required this.id,
    required this.companyId,
    required this.description,
    required this.date,
    required this.transactions,
    required this.source,
    this.referenceId,
    this.currency,
    this.metadata,
  });

  factory JournalEntry.fromFirestore(
      Map<String, dynamic> data, String documentId) {
    return JournalEntry(
      id: documentId,
      companyId: data['companyId'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      transactions: (data['transactions'] as List<dynamic>? ?? [])
          .map((t) => TransactionModel.fromFirestore(t as Map<String, dynamic>))
          .toList(),
      source: data['source'] ?? 'other',
      referenceId: data['referenceId'],
      currency: data['currency'],
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'companyId': companyId,
      'description': description,
      'date': Timestamp.fromDate(date),
      'transactions': transactions.map((t) => t.toFirestore()).toList(),
      'source': source,
      'referenceId': referenceId,
      'currency': currency,
      'metadata': metadata,
    };
  }
}
