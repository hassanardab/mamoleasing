
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../models/booking_event.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final events = bookingProvider.events;

    final totalBookings = events.length;
    final totalRevenue = events.fold<double>(0, (sum, event) => sum + event.amount);
    final confirmedBookings = events.where((e) => e.status == BookingStatus.confirmed).length;
    final cancelledBookings = events.where((e) => e.status == BookingStatus.cancelled).length;
    
    final confirmationRate = totalBookings > 0 ? (confirmedBookings / totalBookings) * 100 : 0;
    final cancellationRate = totalBookings > 0 ? (cancelledBookings / totalBookings) * 100 : 0;

    return GridView.count(
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: <Widget>[
        _buildStatCard(context, 'Total Bookings', totalBookings.toString(), Icons.event, Colors.blue),
        _buildStatCard(context, 'Total Revenue', '\$${totalRevenue.toStringAsFixed(2)}', Icons.attach_money, Colors.green),
        _buildStatCard(context, 'Confirmation Rate', '${confirmationRate.toStringAsFixed(1)}%', Icons.check_circle_outline, Colors.orange),
        _buildStatCard(context, 'Cancellation Rate', '${cancellationRate.toStringAsFixed(1)}%', Icons.cancel_outlined, Colors.red),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(value, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
