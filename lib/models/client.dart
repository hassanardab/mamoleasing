import 'package:cloud_firestore/cloud_firestore.dart';

class Client {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final List<String>? phones;
  final String? address;
  final double balance;

  Client({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.phones,
    this.address,
    this.balance = 0,
  });

  factory Client.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Client(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'],
      phone: data['phone'],
      phones: data['phones'] != null ? List<String>.from(data['phones']) : null,
      address: data['address'],
      balance: (data['balance'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'phones': phones,
      'address': address,
      'balance': balance,
    };
  }
}
