import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/booking_event.dart';
import '../booking/add_event_dialog.dart';

class EventDetailsScreen extends StatelessWidget {
  final BookingEvent event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AddEventDialog(event: event),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // TODO: Implement delete functionality
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Customer:', event.customerName),
            _buildDetailRow(
                'Dates:',
                '${DateFormat.yMd().format(event.startDate)} - ${DateFormat.yMd().format(event.endDate)}'),
            _buildDetailRow('Status:', event.status.name),
            _buildDetailRow('Amount:', '${event.amount} ${event.currency}'),
            _buildDetailRow('Balance:', '${event.balance} ${event.currency}'),
            if (event.notes != null && event.notes!.isNotEmpty)
              _buildDetailRow('Notes:', event.notes!),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
