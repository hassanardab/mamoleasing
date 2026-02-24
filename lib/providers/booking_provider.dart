import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_event.dart';
import 'dart:developer' as developer;

class BookingProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _companyId;
  StreamSubscription<QuerySnapshot>? _eventsSubscription;

  bool _loading = false;
  List<BookingEvent> _events = [];
  DateTime _selectedDate = DateTime.now();
  String _searchQuery = '';

  bool get loading => _loading;
  List<BookingEvent> get events => _events;
  DateTime get selectedDate => _selectedDate;
  String get searchQuery => _searchQuery;

  List<BookingEvent> get filteredEvents {
    final eventsForDate = _events
        .where((event) => isSameDay(event.startDate, _selectedDate))
        .toList();
    if (_searchQuery.isEmpty) return eventsForDate;
    final query = _searchQuery.toLowerCase();
    return eventsForDate
        .where((event) =>
            event.title.toLowerCase().contains(query) ||
            event.customerName.toLowerCase().contains(query) ||
            (event.place?.toLowerCase().contains(query) ?? false))
        .toList();
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    super.dispose();
  }

  void _subscribeToEvents() {
    _eventsSubscription?.cancel();
    if (_companyId == null || _companyId!.isEmpty) {
      _events = [];
      _loading = false;
      notifyListeners();
      return;
    }

    _loading = true;
    notifyListeners();

    final query = _firestore
        .collection('companies')
        .doc(_companyId!)
        .collection('bookingEvents')
        .orderBy('startDate', descending: false);

    _eventsSubscription = query.snapshots().listen((snapshot) {
      _events = snapshot.docs
          .map((doc) => BookingEvent.fromFirestore(doc.data(), doc.id))
          .toList();
      _loading = false;
      notifyListeners();
    }, onError: (error) {
      developer.log("Error fetching events", error: error);
      _loading = false;
      notifyListeners();
    });
  }

  void updateCompanyId(String? newCompanyId) {
    if (_companyId != newCompanyId) {
      _companyId = newCompanyId;
      _subscribeToEvents();
    }
  }

  Future<void> refreshEvents() async {
    _subscribeToEvents();
  }

  Future<void> addEvent(String companyId, BookingEvent event) async {
    await _firestore
        .collection('companies')
        .doc(companyId)
        .collection('bookingEvents')
        .add(event.toFirestore());
  }

  Future<void> updateEvent(String companyId, BookingEvent event) async {
    if (event.id == null) return;
    await _firestore
        .collection('companies')
        .doc(companyId)
        .collection('bookingEvents')
        .doc(event.id)
        .update(event.toFirestore());
  }

  Future<void> deleteEvent(String companyId, String eventId) async {
    await _firestore
        .collection('companies')
        .doc(companyId)
        .collection('bookingEvents')
        .doc(eventId)
        .delete();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
