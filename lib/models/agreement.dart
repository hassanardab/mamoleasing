import 'package:cloud_firestore/cloud_firestore.dart';

class Agreement {
  final String id;
  final String vehicleId;
  final String clientId;
  final DateTime startDate;
  final DateTime endDate;
  final String terms;
  final String insuranceDetails;
  final double initialMileage;
  final double initialFuelLevel;
  final String status;

  Agreement({
    required this.id,
    required this.vehicleId,
    required this.clientId,
    required this.startDate,
    required this.endDate,
    required this.terms,
    required this.insuranceDetails,
    required this.initialMileage,
    required this.initialFuelLevel,
    required this.status,
  });

  factory Agreement.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Agreement(
      id: documentId,
      vehicleId: data['vehicleId'] ?? '',
      clientId: data['clientId'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      terms: data['terms'] ?? '',
      insuranceDetails: data['insuranceDetails'] ?? '',
      initialMileage: (data['initialMileage'] ?? 0).toDouble(),
      initialFuelLevel: (data['initialFuelLevel'] ?? 0).toDouble(),
      status: data['status'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'vehicleId': vehicleId,
      'clientId': clientId,
      'startDate': startDate,
      'endDate': endDate,
      'terms': terms,
      'insuranceDetails': insuranceDetails,
      'initialMileage': initialMileage,
      'initialFuelLevel': initialFuelLevel,
      'status': status,
    };
  }
}
