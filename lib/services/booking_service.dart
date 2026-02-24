import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_event.dart';
import '../models/client.dart';
import '../models/place.dart';

class BookingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String companyId;

  BookingService(this.companyId);

  // Booking Events
  Stream<List<BookingEvent>> getBookingEvents() {
    return _db
        .collection('companies')
        .doc(companyId)
        .collection('bookingEvents')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingEvent.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<void> addBookingEvent(BookingEvent event) async {
    await _db
        .collection('companies')
        .doc(companyId)
        .collection('bookingEvents')
        .add(event.toFirestore());
  }

  Future<void> updateBookingEvent(BookingEvent event) async {
    await _db
        .collection('companies')
        .doc(companyId)
        .collection('bookingEvents')
        .doc(event.id)
        .update(event.toFirestore());
  }

  Future<void> deleteBookingEvent(String eventId) async {
    await _db
        .collection('companies')
        .doc(companyId)
        .collection('bookingEvents')
        .doc(eventId)
        .delete();
  }

  // Clients
  Stream<List<Client>> getClients() {
    return _db
        .collection('companies')
        .doc(companyId)
        .collection('clients')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Client.fromFirestore(doc)).toList());
  }

  Future<DocumentReference> addClient(Client client) async {
    return await _db
        .collection('companies')
        .doc(companyId)
        .collection('clients')
        .add(client.toFirestore());
  }

  // Places
  Stream<List<Place>> getPlaces() {
    return _db
        .collection('companies')
        .doc(companyId)
        .collection('places')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Place.fromFirestore(doc)).toList());
  }

  Future<DocumentReference> addPlace(Place place) async {
    return await _db
        .collection('companies')
        .doc(companyId)
        .collection('places')
        .add(place.toFirestore());
  }
}
