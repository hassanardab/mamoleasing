
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/booking_provider.dart';
import 'booking/add_event_dialog.dart';
import 'booking/calendar_view.dart';
import 'booking/events_list.dart';
import 'booking/stats_grid.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure the booking provider is updated with the latest company ID
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    bookingProvider.updateCompanyId(appProvider.selectedModuleId);
  }


  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);

    // Listen for changes in AppProvider to update the booking provider
    // This is a common pattern for dependent providers.
    final companyId = context.watch<AppProvider>().selectedModuleId;
    bookingProvider.updateCompanyId(companyId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
               final companyId = Provider.of<AppProvider>(context, listen: false).selectedModuleId;
               if(companyId != null && companyId.isNotEmpty) {
                  bookingProvider.fetchEvents(companyId);
               }
            },
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: Row(
        children: <Widget>[
          // Main Content Area
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const StatsGrid(),
                  const SizedBox(height: 16),
                  Expanded(child: CalendarView()),
                ],
              ),
            ),
          ),

          // Side Panel for Events
          Expanded(
            flex: 2,
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: const EventsList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AddEventDialog();
            },
          );
        },
        label: const Text('Add Event'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
