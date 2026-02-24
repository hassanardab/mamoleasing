import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';
import 'booking/add_event_dialog.dart';
import 'booking/calendar_view.dart';
import 'booking/events_list.dart';
import 'booking/stats_grid.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              Provider.of<BookingProvider>(context, listen: false)
                  .selectDate(DateTime.now());
            },
            tooltip: 'Go to Today',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            // Wide screen layout
            return _buildWideLayout(context);
          } else {
            // Narrow screen layout
            return _buildNarrowLayout(context);
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => const AddEventDialog(),
        ),
        label: const Text('Add Event'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          flex: 3,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                StatsGrid(),
                SizedBox(height: 16),
                Expanded(child: CalendarView()),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withAlpha(128),
            child: const EventsList(),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const StatsGrid(),
            const SizedBox(height: 16),
            const CalendarView(),
            const SizedBox(height: 16),
            SizedBox(
              height: 500, // Constrain height for the list in a scroll view
              child: Container(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withAlpha(128),
                child: const EventsList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
