
import 'package:flutter/material.dart';
import '../models/vehicle.dart';

class VehicleDetailsScreen extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleDetailsScreen({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${vehicle.make} ${vehicle.model}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${vehicle.year} ${vehicle.make} ${vehicle.model}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            // Placeholder for image carousel
            Container(
              height: 200,
              color: Colors.grey[300],
              child: const Center(
                child: Text('Image Carousel Placeholder'),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Text(
              vehicle.description ?? 'No description available.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
