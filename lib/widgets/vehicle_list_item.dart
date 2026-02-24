import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../screens/vehicle_details_screen.dart';
import '../screens/create_agreement_screen.dart';

class VehicleListItem extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleListItem({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text('${vehicle.make} ${vehicle.model}'),
        subtitle: Text('Year: ${vehicle.year} | Status: ${vehicle.status}'),
        trailing: vehicle.status == 'Available'
            ? ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateAgreementScreen(vehicle: vehicle),
                    ),
                  );
                },
                child: const Text('Create Agreement'),
              )
            : ElevatedButton(
                onPressed: null,
                child: const Text('Rented'),
              ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VehicleDetailsScreen(vehicle: vehicle),
            ),
          );
        },
      ),
    );
  }
}
