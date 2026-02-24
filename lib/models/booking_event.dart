import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus { confirmed, postponed, pending, partiallyPaid, cancelled }

class BookingEvent {
  final String id;
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
    required this.id,
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
    return BookingEvent(
      id: id,
      title: data['title'] ?? '',
      customerName: data['customerName'] ?? '',
      customerEmail: data['customerEmail'],
      customerPhone: data['customerPhone'],
      customerPhones: data['customerPhones'] != null ? List<String>.from(data['customerPhones']) : null,
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      amount: (data['amount'] ?? 0).toDouble(),
      balance: (data['balance'] ?? 0).toDouble(),
      paidAmount: (data['paidAmount'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'USD',
      status: _parseStatus(data['status']),
      place: data['place'],
      notes: data['notes'],
      description: data['description'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      clientId: data['clientId'],
      placeId: data['placeId'],
      source: data['source'],
      baseCurrencyAmount: (data['baseCurrencyAmount'] ?? 0).toDouble(),
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
    switch (status) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'postponed':
        return BookingStatus.postponed;
      case 'pending':
        return BookingStatus.pending;
      case 'partially_paid':
        return BookingStatus.partiallyPaid;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }
}
