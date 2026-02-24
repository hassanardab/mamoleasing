import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../models/booking_event.dart';
import 'package:intl/intl.dart';

import 'event_details_screen.dart';

class BookingListScreen extends StatelessWidget {
  const BookingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Bookings'),
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, child) {
          if (bookingProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (bookingProvider.events.isEmpty) {
            return const Center(
              child: Text('No bookings found.'),
            );
          }

          return ListView.builder(
            itemCount: bookingProvider.events.length,
            itemBuilder: (context, index) {
              final event = bookingProvider.events[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(event.title),
                  subtitle: Text(
                      '${DateFormat.yMd().format(event.startDate)} - ${DateFormat.yMd().format(event.endDate)} - ${event.status.name}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailsScreen(event: event),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
