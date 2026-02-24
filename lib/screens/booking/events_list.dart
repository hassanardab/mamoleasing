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
    final events = bookingProvider.filteredEvents;

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
            onChanged: bookingProvider.setSearchQuery,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          child: Text(
            'Events for ${DateFormat.yMMMd().format(bookingProvider.selectedDate)}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: bookingProvider.loading
              ? const Center(child: CircularProgressIndicator())
              : events.isEmpty
                  ? Center(child: Text('No events found.', style: Theme.of(context).textTheme.bodyLarge))
                  : ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return Card(
                          elevation: 2.0,
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: InkWell(
                            onTap: () => showDialog(
                              context: context,
                              builder: (context) => EventDetailsDialog(event: event),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(event.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.person, size: 16, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Text(event.customerName, style: Theme.of(context).textTheme.titleMedium),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildInfoChip(context, Icons.access_time, '${DateFormat.jm().format(event.startDate)} - ${DateFormat.jm().format(event.endDate)}'),
                                      _buildStatusChip(context, event.status),
                                    ],
                                  ),
                                  const Divider(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildCurrencyInfo(context, 'Amount', event.amount, Colors.blueGrey),
                                      _buildCurrencyInfo(context, 'Paid', event.paidAmount ?? 0, Colors.green),
                                      _buildCurrencyInfo(context, 'Balance', event.balance, Colors.red),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(BuildContext context, BookingStatus status) {
    return Chip(
      avatar: Icon(Icons.circle, size: 12, color: _getStatusColor(status)),
      label: Text(
        status.name.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: _getStatusColor(status)),
      ),
      backgroundColor: _getStatusColor(status).withOpacity(0.1),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(text, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
  
  Widget _buildCurrencyInfo(BuildContext context, String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }


  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return Colors.green.shade700;
      case BookingStatus.pending:
        return Colors.blue.shade700;
      case BookingStatus.cancelled:
        return Colors.red.shade700;
      case BookingStatus.partiallyPaid:
        return Colors.orange.shade800;
      case BookingStatus.postponed:
        return Colors.purple.shade700;
    }
  }
}
