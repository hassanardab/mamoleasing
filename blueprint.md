## **App Overview**
This is a Flutter application for managing a vehicle rental business. It allows users to manage their vehicle inventory, clients, and rental agreements.

## **Features**

*   **Authentication**: Users can sign up and log in using Firebase Authentication.
*   **Multi-Company Support**: The application supports multiple companies, with each user having access to a specific set of companies.
*   **Vehicle Inventory Management**: Users can add, view, and manage their vehicle inventory.
*   **Client Management**: Users can add and view their clients.
*   **Rental Agreements**: Users can view their rental agreements.

## **Architecture**

*   **State Management**: The application uses the `provider` package for state management. A centralized `AppProvider` manages the application's state, including authentication, user data, and the selected company.
*   **Routing**: The application uses the `go_router` package for routing. The router listens to the `AppProvider` for authentication changes and redirects users accordingly. The router has a dedicated `/splash` route to handle the initial loading state and prevent redirect loops.
*   **Backend**: The application uses Firebase for its backend, including Firebase Authentication and Cloud Firestore for the database.

## **Security**
*   **Firestore Rules**: The application uses a multi-tenant security model. Data access is restricted to authenticated users who are members or owners of a specific company. A super admin has global access to all data.

## **File Structure**

```
lib/
|-- models/
|   |-- agreement.dart
|   |-- client.dart
|   |-- vehicle.dart
|-- providers/
|   |-- app_provider.dart
|-- screens/
|   |-- add_vehicle_screen.dart
|   |-- agreement_details_screen.dart
|   |-- agreements_screen.dart
|   |-- login_screen.dart
|   |-- manage_clients_screen.dart
|   |-- splash_screen.dart
|   |-- vehicle_inventory_screen.dart
|-- widgets/
|   |-- vehicle_list_item.dart
|-- main.dart
|-- router.dart
```
