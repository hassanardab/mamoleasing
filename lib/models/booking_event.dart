import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus { confirmed, postponed, pending, partiallyPaid, cancelled }

class BookingEvent {
  final String? id;
  final String title;
  final String customerName;
  final String? customerEmail;
  final String? customerPhone;
  final List<String>? customerPhones;
  final DateTime startDate;
  final DateTime endDate;
  final double amount;
  final double balance;
  final double? paidAmount;
  final String currency;
  final BookingStatus status;
  final String? place;
  final String? notes;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? clientId;
  final String? placeId;
  final String? source;
  final double? baseCurrencyAmount;

  BookingEvent({
    this.id,
    required this.title,
    required this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.customerPhones,
    required this.startDate,
    required this.endDate,
    required this.amount,
    required this.balance,
    this.paidAmount,
    required this.currency,
    required this.status,
    this.place,
    this.notes,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.clientId,
    this.placeId,
    this.source,
    this.baseCurrencyAmount,
  });

  factory BookingEvent.fromFirestore(Map<String, dynamic> data, String id) {
    // Helper to safely parse timestamps
    DateTime parseDate(Timestamp? timestamp) {
      return timestamp?.toDate() ?? DateTime.now();
    }

    return BookingEvent(
      id: id,
      title: data['title'] as String? ?? '',
      customerName: data['customerName'] as String? ?? '',
      customerEmail: data['customerEmail'] as String?,
      customerPhone: data['customerPhone'] as String?,
      customerPhones: data['customerPhones'] != null
          ? List<String>.from(data['customerPhones'])
          : null,
      startDate: parseDate(data['startDate'] as Timestamp?),
      endDate: parseDate(data['endDate'] as Timestamp?),
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      balance: (data['balance'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (data['paidAmount'] as num?)?.toDouble() ?? 0.0,
      currency: data['currency'] as String? ?? 'USD',
      status: _parseStatus(data['status'] as String?),
      place: data['place'] as String?,
      notes: data['notes'] as String?,
      description: data['description'] as String?,
      createdAt: parseDate(data['createdAt'] as Timestamp?),
      updatedAt: parseDate(data['updatedAt'] as Timestamp?),
      clientId: data['clientId'] as String?,
      placeId: data['placeId'] as String?,
      source: data['source'] as String?,
      baseCurrencyAmount: (data['baseCurrencyAmount'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'customerPhones': customerPhones,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'amount': amount,
      'balance': balance,
      'paidAmount': paidAmount,
      'currency': currency,
      'status': status.name,
      'place': place,
      'notes': notes,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'clientId': clientId,
      'placeId': placeId,
      'source': source,
      'baseCurrencyAmount': baseCurrencyAmount,
    };
  }

  static BookingStatus _parseStatus(String? status) {
    if (status == null) return BookingStatus.pending;
    try {
      return BookingStatus.values.firstWhere((e) => e.name == status);
    } catch (e) {
      return BookingStatus.pending; // Default fallback
    }
  }
}
