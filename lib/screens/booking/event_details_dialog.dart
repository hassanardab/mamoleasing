import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/booking_event.dart';
import '../../providers/app_provider.dart';
import '../../providers/booking_provider.dart';
import '../../utils/colors.dart';
import 'add_event_dialog.dart';

class EventDetailsDialog extends StatelessWidget {
  final BookingEvent event;

  const EventDetailsDialog({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildCustomerInfo(context),
              const Divider(height: 30),
              _buildEventTiming(context),
              const Divider(height: 30),
              _buildFinancialDetails(context),
              const SizedBox(height: 24),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(event.title,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ),
        Chip(
          avatar:
              Icon(Icons.circle, size: 12, color: getStatusColor(event.status)),
          label: Text(
            event.status.name.toUpperCase(),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: getStatusColor(event.status)),
          ),
          backgroundColor: getStatusColor(event.status).withOpacity(0.1),
        ),
      ],
    );
  }

  Widget _buildCustomerInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CUSTOMER',
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: Colors.grey)),
        const SizedBox(height: 8),
        _buildInfoRow(context, Icons.person, event.customerName,
            style: Theme.of(context).textTheme.titleMedium),
        if (event.customerEmail != null && event.customerEmail!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: _buildInfoRow(context, Icons.email, event.customerEmail!),
          ),
        if (event.customerPhone != null && event.customerPhone!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: _buildInfoRow(context, Icons.phone, event.customerPhone!),
          ),
      ],
    );
  }

  Widget _buildEventTiming(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('TIMING',
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: Colors.grey)),
        const SizedBox(height: 8),
        _buildInfoRow(context, Icons.calendar_today,
            'From: ${DateFormat.yMMMd().add_jm().format(event.startDate)}'),
        const SizedBox(height: 8),
        _buildInfoRow(context, Icons.calendar_today,
            'To:      ${DateFormat.yMMMd().add_jm().format(event.endDate)}'),
        if (event.place != null && event.place!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: _buildInfoRow(context, Icons.location_on, event.place!),
          ),
      ],
    );
  }

  Widget _buildFinancialDetails(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCurrencyInfo(context, 'Amount', event.amount,
            Theme.of(context).colorScheme.onSurface),
        _buildCurrencyInfo(
            context, 'Paid', event.paidAmount ?? 0, Colors.green),
        _buildCurrencyInfo(context, 'Balance', event.balance, Colors.red),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteEvent(context),
          tooltip: 'Delete Event',
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.edit),
          label: const Text('Edit'),
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
            showDialog(
              context: context,
              builder: (ctx) => AddEventDialog(event: event),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text,
      {TextStyle? style}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(text, style: style ?? Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }

  Widget _buildCurrencyInfo(
      BuildContext context, String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  void _deleteEvent(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final companyId = appProvider.selectedModuleId;

    if (companyId == null || companyId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Cannot delete event: Company ID not found.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text(
            'Do you want to delete this event? This action cannot be undone.'),
        actions: <Widget>[
          TextButton(
              child: const Text('No'),
              onPressed: () => Navigator.of(ctx).pop()),
          TextButton(
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              try {
                await Provider.of<BookingProvider>(context, listen: false)
                    .deleteEvent(companyId, event.id!);
                Navigator.of(ctx).pop(); // Close confirmation dialog
                Navigator.of(context).pop(); // Close details dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Event deleted successfully.'),
                      backgroundColor: Colors.green),
                );
              } catch (e) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Failed to delete event: $e'),
                      backgroundColor: Colors.red),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
