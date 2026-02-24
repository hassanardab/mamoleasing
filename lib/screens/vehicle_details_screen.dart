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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${vehicle.year} ${vehicle.make} ${vehicle.model}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Status: ${vehicle.status}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: vehicle.status == 'Available' ? Colors.green : Colors.orange,
                      fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Pre-Rental Images',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              vehicle.preRentalImages.isEmpty
                  ? Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text('No pre-rental images uploaded.'),
                      ),
                    )
                  : SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: vehicle.preRentalImages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                vehicle.preRentalImages[index],
                                width: 250,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  return progress == null
                                      ? child
                                      : const Center(child: CircularProgressIndicator());
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 250,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.error, color: Colors.red),
                                  );
                                },
                              ),
                            ),
                          );
                        },
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
      ),
    );
  }
}
