
import 'dart:typed_data';

class Vehicle {
  final String id;
  final String make;
  final String model;
  final int year;
  final String? description;
  final List<Uint8List> images;

  Vehicle({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    this.description,
    this.images = const [],
  });
}
