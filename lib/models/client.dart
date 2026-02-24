class Client {
  final String id;
  final String name;
  final String driverLicenseId;
  final String contactInfo;
  final List<String> rentalHistory;

  Client({
    required this.id,
    required this.name,
    required this.driverLicenseId,
    required this.contactInfo,
    required this.rentalHistory,
  });

  factory Client.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Client(
      id: documentId,
      name: data['name'] ?? '',
      driverLicenseId: data['driverLicenseId'] ?? '',
      contactInfo: data['contactInfo'] ?? '',
      rentalHistory: List<String>.from(data['rentalHistory'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'driverLicenseId': driverLicenseId,
      'contactInfo': contactInfo,
      'rentalHistory': rentalHistory,
    };
  }
}
