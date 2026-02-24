import 'package:cloud_firestore/cloud_firestore.dart';

class Place {
  final String id;
  final String name;
  final String? address;

  Place({required this.id, required this.name, this.address});

  factory Place.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Place(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'address': address,
    };
  }
}
