## **App Overview**
This is a Flutter application for managing a vehicle rental business. It allows users to manage their vehicle inventory, clients, rental agreements, and bookings.

## **Features**

*   **Authentication**: Users can sign up and log in using Firebase Authentication.
*   **Multi-Company Support**: The application supports multiple companies, with each user having access to a specific set of companies.
*   **Vehicle Inventory Management**: Users can add, view, and manage their vehicle inventory.
*   **Vehicle Image Management**: Users can upload an image for each vehicle, which is displayed in the vehicle list.
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
*   **Backend**: Firebase (Authentication, Cloud Firestore, Firebase Storage).

## **Style & Design**
*   **Theme**: Material 3 with a custom color scheme derived from a seed color.
*   **Icons**: Standard Material Icons for a native feel.
*   **Typography**: Google Fonts (Roboto/Open Sans).
*   **Responsiveness**: Layout adapts to screen size using `LayoutBuilder` and `MediaQuery`.

## **Recent Changes**

### Vehicle Image Feature
*   **Dependencies**: Added `image_picker` for selecting images from the device gallery and `firebase_storage` for uploading and storing them.
*   **Add Vehicle Screen**: Implemented functionality to allow users to pick an image when adding a new vehicle. The selected image is displayed on the screen before saving.
*   **Image Upload**: Upon saving, the selected image is uploaded to Firebase Storage under a structured path: `companies/{companyId}/vehicles/{vehicleId}/images/{fileName}`.
*   **Data Model**: The `Vehicle` model has been updated to include an `imageUrl` field, which stores the public download URL of the uploaded image.
*   **Vehicle List Display**: The main vehicle inventory list has been updated to display a thumbnail of each vehicle's image. A placeholder icon is shown if a vehicle has no image.

### Code Health and Bug Fixes
*   **Deprecation Fixes**: Resolved several deprecation warnings throughout the project. Notably, `withOpacity` has been replaced with the more efficient `withAlpha` for color adjustments.
*   **Enum Handling**: Corrected the logic in the booking section for handling `BookingStatus` enums, making the status display more robust.
*   **General Cleanup**: Performed various minor code cleanup tasks to improve readability and maintainability.

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
