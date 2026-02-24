
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/booking_event.dart';
import '../../providers/booking_provider.dart';
import 'event_details_dialog.dart';

class EventsList extends StatelessWidget {
  const EventsList({super.key});

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final events = bookingProvider.selectedDateEvents;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Search Events',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              bookingProvider.setSearchQuery(value);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Events for ${DateFormat.yMMMd().format(bookingProvider.selectedDate)}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Expanded(
          child: bookingProvider.loading
              ? const Center(child: CircularProgressIndicator())
              : events.isEmpty
                  ? const Center(child: Text('No events for this day.'))
                  : ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: ListTile(
                            title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(event.customerName),
                            trailing: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('\$${event.amount.toStringAsFixed(2)}'),
                                Chip(
                                  label: Text(event.status.name, style: const TextStyle(fontSize: 10)),
                                  backgroundColor: _getStatusColor(event.status).withAlpha(51),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => EventDetailsDialog(event: event),
                              );
                            },
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.pending:
        return Colors.blue;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.partiallyPaid:
        return Colors.deepOrange;
      case BookingStatus.postponed:
        return Colors.purple;
    }
  }
}
