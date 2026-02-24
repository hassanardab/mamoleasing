import 'package:cloud_firestore/cloud_firestore.dart';

class Inspection {
  final String id;
  final String agreementId;
  final DateTime date;
  final double mileage;
  final double fuelLevel;
  final List<String> images;
  final String notes;

  Inspection({
    required this.id,
    required this.agreementId,
    required this.date,
    required this.mileage,
    required this.fuelLevel,
    required this.images,
    required this.notes,
  });

  factory Inspection.fromFirestore(
      Map<String, dynamic> data, String documentId) {
    return Inspection(
      id: documentId,
      agreementId: data['agreementId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      mileage: (data['mileage'] ?? 0).toDouble(),
      fuelLevel: (data['fuelLevel'] ?? 0).toDouble(),
      images: List<String>.from(data['images'] ?? []),
      notes: data['notes'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'agreementId': agreementId,
      'date': date,
      'mileage': mileage,
      'fuelLevel': fuelLevel,
      'images': images,
      'notes': notes,
    };
  }
}
