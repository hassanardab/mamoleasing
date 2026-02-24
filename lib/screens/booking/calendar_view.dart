import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/booking_event.dart';
import '../../providers/booking_provider.dart';
import '../../utils/colors.dart';

class CalendarView extends StatelessWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TableCalendar<BookingEvent>(
          firstDay: DateTime.utc(2010, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: bookingProvider.selectedDate,
          selectedDayPredicate: (day) => isSameDay(bookingProvider.selectedDate, day),
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.monday,
          eventLoader: (day) => bookingProvider.events.where((event) => isSameDay(event.startDate, day)).toList(),
          onDaySelected: (selectedDay, focusedDay) {
            bookingProvider.selectDate(selectedDay);
          },
          onPageChanged: (focusedDay) {
            bookingProvider.selectDate(focusedDay); // Update the provider when the month changes
          },
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            todayDecoration: BoxDecoration(
              color: theme.primaryColor.withAlpha(77),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: theme.primaryColor,
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: theme.colorScheme.secondary,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
            titleTextStyle: theme.textTheme.titleLarge!,
            leftChevronIcon: Icon(Icons.chevron_left, color: theme.primaryColor),
            rightChevronIcon: Icon(Icons.chevron_right, color: theme.primaryColor),
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isEmpty) return null;
              return Positioned(
                right: 1,
                bottom: 1,
                child: _buildEventsMarker(context, date, events),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEventsMarker(BuildContext context, DateTime date, List<BookingEvent> events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: getStatusColor(events.first.status).withAlpha(204),
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
