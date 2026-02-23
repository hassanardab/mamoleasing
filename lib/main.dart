
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import './models/vehicle.dart';
import './widgets/vehicle_list_item.dart';
import './screens/add_vehicle_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vehicle Rental Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const VehicleInventory(),
    );
  }
}

class VehicleInventory extends StatefulWidget {
  const VehicleInventory({super.key});

  @override
  State<VehicleInventory> createState() => _VehicleInventoryState();
}

class _VehicleInventoryState extends State<VehicleInventory> {
    final List<Vehicle> _vehicles = [
    Vehicle(id: '1', make: 'Toyota', model: 'Camry', year: 2022),
    Vehicle(id: '2', make: 'Honda', model: 'Accord', year: 2023),
    Vehicle(id: '3', make: 'Ford', model: 'Mustang', year: 2021),
  ];

  void _addVehicle(Vehicle? newVehicle) {
    if (newVehicle != null) {
      setState(() {
        _vehicles.add(newVehicle);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Inventory'),
      ),
      body: ListView.builder(
        itemCount: _vehicles.length,
        itemBuilder: (context, index) {
          return VehicleListItem(vehicle: _vehicles[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newVehicle = await Navigator.push<Vehicle>(
            context,
            MaterialPageRoute(builder: (context) => const AddVehicleScreen()),
          );
          _addVehicle(newVehicle);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
