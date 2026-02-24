
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/booking_provider.dart';
import '../../models/booking_event.dart';

class CalendarView extends StatelessWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TableCalendar<BookingEvent>(
          firstDay: DateTime.utc(2010, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: bookingProvider.selectedDate,
          selectedDayPredicate: (day) => isSameDay(bookingProvider.selectedDate, day),
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.monday,
          eventLoader: (day) {
            return bookingProvider.events.where((event) => isSameDay(event.startDate, day)).toList();
          },
          onDaySelected: (selectedDay, focusedDay) {
            bookingProvider.selectDate(selectedDay);
            bookingProvider.setCurrentDate(focusedDay);
          },
          onPageChanged: (focusedDay) {
             bookingProvider.setCurrentDate(focusedDay);
          },
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            todayDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withAlpha(128),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
          ),
        ),
      ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
