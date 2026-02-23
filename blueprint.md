# App Blueprint

## Overview

A comprehensive vehicle rental management application designed to streamline the entire rental process, from inventory management to final invoicing. The app incorporates AI-powered tools for damage assessment, data extraction, and content generation, aiming to improve efficiency and accuracy.

## Features

*   **Vehicle Inventory**: Add new vehicles to the inventory, including details like make, model, and year. The app provides a clear list of all vehicles.
*   **AI-Generated Vehicle Descriptions**: When adding a new vehicle, the app can automatically generate an engaging rental description using a generative AI model (Gemini).
*   **Vehicle Details Screen**: View detailed information about each vehicle, including the AI-generated description and a placeholder for an image carousel.
*   **Rental Booking & Tracking**: Manage rental agreements by recording client details, rental duration, agreed pricing, and automate tracking of active rentals. Provides an overview of current and upcoming bookings.
*   **Post-Rental Mileage & Surcharge Calculation**: A dedicated form for entering post-rental mileage. The system automatically calculates if the agreed-upon mileage limit has been exceeded and determines any applicable surcharges.
*   **AI-Powered Visual Damage Assessment Tool**: Allow users to upload new images of the vehicle after rental. An AI-powered tool will analyze these images by comparing them against the initial pre-rental images to detect potential new damages or discrepancies also allow the user take pictures for car dashboard and clients driver license and then extract information from them for better and faster way to extract info.
*   **Invoice Generation & Sharing**: Generate professional invoices based on rental agreements, mileage surcharges, and any detected damages. Users can print or securely share invoices with clients digitally.
*   **Notification & Reminder System**: Send automated in-app notifications or email reminders to users regarding upcoming rental returns, status updates, or actions required for a seamless management process.
*   **Basic Transaction Logging**: Upon payment confirmation, the application will record essential rental transactions, forming a foundational ledger for financial overview.

## Design & Style

*   **Layout**: Adopt a responsive, dashboard-style layout with clear information hierarchy. Panels and cards should organize data logically, ensuring usability on various screen sizes.
*   **Color**: A `primarySwatch` of `Colors.blue` is used for the main theme.
*   **Typography**: Body and headline font: 'Inter' (sans-serif) for its modern, clear, and objective readability across all textual content, ideal for a management application.
*   **Iconography**: Utilize a consistent set of clean, outline-style icons to maintain a professional and uncluttered aesthetic throughout the application, enhancing navigability.
*   **Animation**: Incorporate subtle and swift transitions for actions such as form submissions, status updates, and view changes, providing clear feedback without distracting the user.
