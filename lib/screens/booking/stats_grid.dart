import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import 'stat_card.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
        return Consumer<BookingProvider>(
          builder: (context, bookingProvider, child) {
            final events = bookingProvider.events;
            final totalBookings = events.length;
            final totalRevenue =
                events.fold<double>(0, (sum, event) => sum + event.amount);
            final totalPaid = events.fold<double>(
                0, (sum, event) => sum + (event.paidAmount ?? 0));
            final upcomingEvents =
                events.where((e) => e.startDate.isAfter(DateTime.now())).length;

            return GridView.count(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: <Widget>[
                StatCard(
                  title: 'Total Bookings',
                  value: totalBookings.toString(),
                  icon: Icons.event_available,
                  color: Colors.blue,
                ),
                StatCard(
                  title: 'Total Revenue',
                  value: '\$${totalRevenue.toStringAsFixed(2)}',
                  icon: Icons.monetization_on,
                  color: Colors.green,
                ),
                StatCard(
                  title: 'Total Collected',
                  value: '\$${totalPaid.toStringAsFixed(2)}',
                  icon: Icons.account_balance_wallet,
                  color: Colors.purple,
                ),
                StatCard(
                  title: 'Upcoming Events',
                  value: upcomingEvents.toString(),
                  icon: Icons.calendar_today,
                  color: Colors.orange,
                ),
              ],
            );
          },
        );
      },
    );
  }
}
