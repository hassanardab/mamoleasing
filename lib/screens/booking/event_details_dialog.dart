
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/booking_event.dart';
import 'add_event_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/app_provider.dart';

class EventDetailsDialog extends StatelessWidget {
  final BookingEvent event;

  const EventDetailsDialog({super.key, required this.event});

  void _deleteEvent(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final companyId = appProvider.selectedModuleId;

    if (companyId == null || companyId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete event: Company ID not found.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Do you want to delete this event? This action cannot be undone.'),
        actions: <Widget>[
          TextButton(
            child: const Text('No'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('companies')
                  .doc(companyId)
                  .collection('bookingEvents')
                  .doc(event.id)
                  .delete();
              Navigator.of(ctx).pop(); // Close confirmation dialog
              Navigator.of(context).pop(); // Close details dialog
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(event.title),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Customer: ${event.customerName}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('From: ${DateFormat.yMd().add_jm().format(event.startDate)}'),
            Text('To: ${DateFormat.yMd().add_jm().format(event.endDate)}'),
            const SizedBox(height: 8),
            if (event.place != null && event.place!.isNotEmpty)
              Text('Place: ${event.place}'),
            const Divider(height: 20),
            Text('Total Amount: \$${event.amount.toStringAsFixed(2)}'),
            Text('Paid: \$${event.paidAmount?.toStringAsFixed(2) ?? '0.00'}'),
            Text('Balance: \$${event.balance.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
            const Divider(height: 20),
            Row(
              children: [
                const Text('Status: '),
                Chip(
                  label: Text(event.status.name),
                  backgroundColor: _getStatusColor(event.status).withAlpha(51),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteEvent(context),
          tooltip: 'Delete Event',
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.edit),
          label: const Text('Edit'),
          onPressed: () {
            Navigator.of(context).pop(); // Close this dialog first
            showDialog(
              context: context,
              builder: (ctx) => AddEventDialog(event: event),
            );
          },
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
