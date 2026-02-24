
import 'package:flutter/material.dart';
import '../models/booking_event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingProvider with ChangeNotifier {
  bool _loading = false;
  List<BookingEvent> _events = [];
  DateTime _selectedDate = DateTime.now();
  DateTime _currentDate = DateTime.now();
  String _searchQuery = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _companyId;
  
  bool get loading => _loading;
  List<BookingEvent> get events => _events;
  DateTime get selectedDate => _selectedDate;
  DateTime get currentDate => _currentDate;
  String get searchQuery => _searchQuery;

  List<BookingEvent> get filteredEvents {
    if (_searchQuery.isEmpty) {
      return _events;
    }
    return _events
        .where((event) =>
            event.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            event.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (event.place?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false))
        .toList();
  }

  void updateCompanyId(String? companyId) {
    if (_companyId != companyId) {
      _companyId = companyId;
      if (_companyId != null && _companyId!.isNotEmpty) {
        fetchEvents(_companyId!);
      } else {
        _events = [];
        _loading = false;
        notifyListeners();
      }
    }
  }

  List<BookingEvent> get selectedDateEvents =>
      _events.where((event) => isSameDay(event.startDate, _selectedDate)).toList();

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setCurrentDate(DateTime date) {
    _currentDate = date;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchEvents(String companyId) async {
    if(companyId.isEmpty) {
      _events = [];
      _loading = false;
      notifyListeners();
      return;
    }
    _loading = true;
    notifyListeners();
    try {
      _firestore
          .collection('companies')
          .doc(companyId)
          .collection('bookingEvents')
          .orderBy('startDate', descending: true)
          .snapshots()
          .listen((snapshot) {
        _events = snapshot.docs
            .map((doc) => BookingEvent.fromFirestore(doc.data(), doc.id))
            .toList();
        _loading = false;
        notifyListeners();
      }, onError: (error) {
         _loading = false;
         print("Error fetching events: $error");
         notifyListeners();
      });
    } catch (e) {
      _loading = false;
      print("Error fetching events: $e");
      notifyListeners();
    }
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
