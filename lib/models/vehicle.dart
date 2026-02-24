class Vehicle {
  final String id;
  final String make;
  final String model;
  final int year;
  final String? description;
  final String status;
  final String? imageUrl;
  final List<String> preRentalImages;

  Vehicle({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    this.description,
    required this.status,
    this.imageUrl,
    this.preRentalImages = const [],
  });

  factory Vehicle.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Vehicle(
      id: documentId,
      make: data['make'] ?? '',
      model: data['model'] ?? '',
      year: data['year'] ?? 0,
      description: data['description'],
      status: data['status'] ?? 'Available',
      imageUrl: data['imageUrl'],
      preRentalImages: List<String>.from(data['preRentalImages'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'make': make,
      'model': model,
      'year': year,
      'description': description,
      'status': status,
      'imageUrl': imageUrl,
      'preRentalImages': preRentalImages,
    };
  }
}
