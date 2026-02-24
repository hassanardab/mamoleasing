## **App Overview**
This is a Flutter application for managing a vehicle rental business. It allows users to manage their vehicle inventory, clients, rental agreements, and bookings.

## **Features**

*   **Authentication**: Users can sign up and log in using Firebase Authentication.
*   **Multi-Company Support**: The application supports multiple companies, with each user having access to a specific set of companies.
*   **Vehicle Inventory Management**: Users can add, view, and manage their vehicle inventory.
*   **Client Management**: Users can add and view their clients.
*   **Rental Agreements**: Users can view their rental agreements.
*   **Booking Management**: 
    *   **Dashboard**: Overview of bookings with statistics (revenue, expected payments, etc.).
    *   **Calendar View**: Interactive calendar to view bookings by date.
    *   **Event Management**: Add, edit, delete, and reschedule booking events.
    *   **Financial Integration**: Track payments (Cash, Bank Transfer) linked to journal entries.
    *   **Responsive Design**: Optimized for both mobile and desktop views.

## **Architecture**

*   **State Management**: The application uses the `provider` package for state management. 
    *   `AppProvider`: Manages authentication, user profile, and selected company.
    *   `BookingProvider`: Manages booking events, statistics, and financial data for the active company.
*   **Routing**: The application uses the `go_router` package for routing.
*   **Backend**: Firebase (Authentication, Cloud Firestore).

## **Style & Design**
*   **Theme**: Material 3 with a custom color scheme derived from a seed color.
*   **Icons**: Standard Material Icons for a native feel.
*   **Typography**: Google Fonts (Roboto/Open Sans).
*   **Responsiveness**: Layout adapts to screen size using `LayoutBuilder` and `MediaQuery`.

## **Current Change Plan: Booking Module Implementation**
1.  **Models**: Created `BookingEvent` model. Need to ensure alignment with Firestore structure used in the React code.
2.  **Provider**: Implement `BookingProvider` to fetch events and journal entries (for financial stats).
3.  **Dashboard Screen**: Rebuild `lib/screens/bookings_screen.dart` with stats, calendar, and lists.
4.  **Components**:
    *   `StatsCard`: For revenue and expected payments.
    *   `BookingCalendar`: Using `table_calendar`.
    *   `BookingListItem`: For the list view.
5.  **Dialogs**:
    *   `AddBookingDialog`: Form to create/edit bookings.
    *   `BookingDetailsDialog`: View details, manage payments, and actions (delete/postpone).

## **File Structure (Updated)**

```
lib/
|-- models/
|   |-- account.dart
|   |-- agreement.dart
|   |-- booking_event.dart
|   |-- client.dart
|   |-- journal_entry.dart
|   |-- transaction.dart
|   |-- vehicle.dart
|-- providers/
|   |-- app_provider.dart
|   |-- booking_provider.dart
|-- screens/
|   |-- add_vehicle_screen.dart
|   |-- agreements_screen.dart
|   |-- bookings_screen.dart
|   |-- login_screen.dart
|   |-- manage_clients_screen.dart
|   |-- module_selection_screen.dart
|   |-- splash_screen.dart
|   |-- vehicle_inventory_screen.dart
|-- widgets/
|   |-- booking/
|   |   |-- stats_grid.dart
|   |   |-- calendar_view.dart
|   |   |-- booking_list.dart
|   |-- vehicle_list_item.dart
|-- main.dart
|-- router.dart
```
