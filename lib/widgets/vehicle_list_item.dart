
import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../screens/vehicle_details_screen.dart';

class VehicleListItem extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleListItem({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text('${vehicle.make} ${vehicle.model}'),
        subtitle: Text('Year: ${vehicle.year}'),
        trailing: const Icon(Icons.arrow_forward_ios),
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
