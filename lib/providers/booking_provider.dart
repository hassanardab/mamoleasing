import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/booking_event.dart';
import '../services/booking_service.dart';
import '../models/client.dart';
import '../models/place.dart';

class BookingProvider extends ChangeNotifier {
  final BookingService _bookingService;

  List<BookingEvent> _events = [];
  List<Client> _clients = [];
  List<Place> _places = [];
  bool _isLoading = false;

  List<BookingEvent> get events => _events;
  List<Client> get clients => _clients;
  List<Place> get places => _places;
  bool get isLoading => _isLoading;

  BookingProvider(String companyId) : _bookingService = BookingService(companyId) {
    _fetchData();
  }

  void _fetchData() {
    _isLoading = true;
    notifyListeners();

    _bookingService.getBookingEvents().listen((events) {
      _events = events;
      notifyListeners();
    });

    _bookingService.getClients().listen((clients) {
      _clients = clients;
      notifyListeners();
    });

    _bookingService.getPlaces().listen((places) {
      _places = places;
      notifyListeners();
    });

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addEvent(BookingEvent event) async {
    await _bookingService.addBookingEvent(event);
  }

  Future<void> updateEvent(BookingEvent event) async {
    await _bookingService.updateBookingEvent(event);
  }

  Future<void> deleteEvent(String eventId) async {
    await _bookingService.deleteBookingEvent(eventId);
  }
}
