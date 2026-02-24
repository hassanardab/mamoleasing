import 'package:flutter/material.dart';
import '../../models/booking_event.dart';

Color getStatusColor(BookingStatus status) {
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
