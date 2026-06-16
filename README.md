# Link Konveksi Master

A Flutter-based textile marketplace prototype designed for convection, garment, and textile product sellers.  
The app includes Google authentication, product catalogue management, customer management, order handling, voucher management, stock tracking, order status tracking, wallet-style revenue summary, shop profile management, reports, wishlist, reviews, and live-selling style navigation.

This repository demonstrates a mobile-first marketplace and seller operations concept for textile businesses.

---

## Overview

Link Konveksi Master is a prototype marketplace app for textile and garment products.  
The project focuses on helping textile sellers manage their storefront, products, customers, orders, stock, vouchers, and basic sales reports through a Flutter mobile application backed by Firebase services.

The app is suitable as a portfolio project showing Flutter UI development, Firebase integration, CRUD workflows, authentication, product image upload, order processing, and seller dashboard features.

---

## Main Features

### Authentication

- Google Sign-In
- Firebase Authentication integration
- Authenticated user-based data separation
- Redirect to home screen after successful login

### Home Dashboard

- Textile marketplace home screen
- Gradient app bar UI
- Banner carousel
- Icon-based feature navigation
- Product gallery section
- Bottom navigation bar
- Primary and secondary menu groups

### Product Catalogue

- Product list management
- Product grid/list view toggle
- Add product
- Edit product
- Delete product
- Product image upload
- Product image storage through Firebase Storage
- Product price formatting in Indonesian Rupiah

### Customer Management

- Add customer
- Edit customer
- Delete customer
- Customer list
- Customer sorting
- Customer address and phone number records

### Order Management

- Add order
- Delete order
- Select customer, product, and voucher
- Quantity and shipping address input
- Total price calculation
- Voucher discount calculation
- Order sorting
- Per-user Firestore order storage

### Voucher Management

- Add voucher
- Edit voucher
- Delete voucher
- Voucher category handling
- Voucher quantity
- Voucher nominal value
- Flat and percentage-style voucher validation concept

### Stock Management

- Product stock overview
- Stock quantity update
- Firestore-based stock persistence
- Product price and stock display

### Order Tracking

- Track customer orders
- Update order status
- Supported order statuses:
  - `baru`
  - `dibayar`
  - `diproses`
  - `dikirim`
  - `selesai`

### Wallet & Revenue Summary

- Wallet-style balance screen
- Total earnings summary
- Deposit, withdraw, and history UI placeholders
- Revenue data calculated from order records

### Reports

- Total revenue
- Total orders
- Total customers
- Most ordered product
- Quantity-based product performance summary

### Shop Profile

- Store owner profile
- Address and phone number
- Profile image upload
- Firebase Storage integration for profile pictures
- Firestore-based profile persistence

### Additional Marketplace Modules

The project also contains navigation and screens for:

- Wishlist
- Review
- Live selling
- Tracking
- Customer page
- Voucher page
- Product catalogue
- Order page
- Report page
- Wallet page
- Stock page
- Store profile

---

## Tech Stack

### Framework

- Flutter
- Dart

### Backend & Cloud Services

- Firebase Core
- Firebase Authentication
- Cloud Firestore
- Firebase Realtime Database
- Firebase Storage

### Authentication

- Google Sign-In
- Firebase Auth

### UI & State Management

- Material UI
- Provider
- Gradient App Bar
- Flutter Carousel Widget

### Media & File Handling

- Image Picker
- Camera
- Permission Handler

### Data & Utility

- Intl
- FL Chart
- Flutter Chart

---

## Project Structure

```txt
link_konveksi_master/
├── android/
├── assets/
│   ├── custom_icons/
│   ├── dummy/
│   ├── images/
│   ├── ic_launcher.png
│   └── splash_logo.png
│
├── ios/
├── lib/
│   ├── customer.dart
│   ├── home_screen.dart
│   ├── live.dart
│   ├── login.dart
│   ├── main.dart
│   ├── order.dart
│   ├── product_catalogue.dart
│   ├── profile.dart
│   ├── report.dart
│   ├── review.dart
│   ├── stock.dart
│   ├── track.dart
│   ├── voucher.dart
│   ├── wallet.dart
│   └── wishlist.dart
│
├── linux/
├── macos/
├── test/
├── web/
├── windows/
├── pubspec.yaml
└── README.md
```

---

## Application Modules

### `main.dart`

Initializes Firebase and launches the app with a textile marketplace theme.

### `login.dart`

Handles Google Sign-In using Firebase Authentication.

### `home_screen.dart`

Main dashboard containing banner carousel, shortcut menu, product gallery, and bottom navigation.

### `product_catalogue.dart`

Manages product CRUD, product images, price formatting, and Firebase product storage.

### `customer.dart`

Manages customer CRUD including name, address, and phone number.

### `order.dart`

Handles order creation, customer/product/voucher selection, total price calculation, and order storage.

### `voucher.dart`

Manages voucher data such as name, category, quantity, and nominal discount value.

### `stock.dart`

Displays and updates product stock quantity.

### `track.dart`

Tracks and updates order status.

### `wallet.dart`

Displays wallet-style revenue summary based on order data.

### `report.dart`

Displays sales and order report summaries.

### `profile.dart`

Manages store owner profile data and profile image upload.

---

## Getting Started

### Prerequisites

Make sure you have installed:

- Flutter SDK
- Dart SDK
- Android Studio or VS Code
- Firebase project
- Android emulator or physical device
- Git

---

## Installation

Clone the repository:

```bash
git clone https://github.com/iraroniyuda/link_konveksi_master.git
cd link_konveksi_master
```

Install dependencies:

```bash
flutter pub get
```

Run the app:

```bash
flutter run
```

---

## Firebase Setup

This project uses Firebase services.

Recommended setup:

1. Create a Firebase project.
2. Register an Android app and/or iOS app.
3. Enable Firebase Authentication.
4. Enable Google Sign-In provider.
5. Enable Cloud Firestore.
6. Enable Firebase Storage.
7. Download Firebase configuration files:
   - `google-services.json` for Android
   - `GoogleService-Info.plist` for iOS
8. Place the files in the proper platform directories.

For Android:

```txt
android/app/google-services.json
```

For iOS:

```txt
ios/Runner/GoogleService-Info.plist
```

---

## Firestore Data Concept

The app stores data under the authenticated user document.

Example structure:

```txt
users/
└── {userId}/
    ├── products/
    ├── customers/
    ├── orders/
    ├── vouchers/
    └── profile/
        └── profile_data
```

This structure keeps each seller's operational data separated by Firebase user ID.

---

## Example Order Status Flow

```txt
baru → dibayar → diproses → dikirim → selesai
```

---

## Assets

The project includes:

- Banner images
- Custom icon assets
- App launcher icon
- Splash logo
- Dummy product images

These assets are registered in `pubspec.yaml`.

---

## Security Notes

For production usage, make sure to configure:

- Firebase Authentication rules
- Firestore security rules
- Firebase Storage security rules
- User-based data access validation
- Image upload validation
- Input validation
- Error handling
- Production-safe Firebase configuration

Never commit:

- Private Firebase service account keys
- Production API secrets
- Admin credentials
- Sensitive configuration values

---

## Current Status

This repository is a prototype and portfolio implementation of a Flutter textile marketplace and seller operations app.

Some production-level setup may require additional work, such as:

- Firebase rules
- More complete marketplace checkout flow
- Payment gateway integration
- Shipping integration
- Admin dashboard
- Product categories
- Search and filtering
- Seller/customer separation
- Notification system
- Better state management
- Automated testing
- Production build configuration

---

## Suggested Improvements

Recommended future improvements:

- Add screenshots for login, home, catalogue, order, stock, report, and profile pages
- Add Firebase setup screenshots
- Add Firestore rules example
- Add demo video or GIF preview
- Add product category filtering
- Add checkout/payment flow
- Add shipping provider integration
- Add notification system
- Add cleaner architecture using feature folders
- Add repository/service layer
- Add Riverpod, Bloc, or structured Provider state management
- Add unit and widget tests
- Add CI/CD workflow for Flutter build

---

## Suggested GitHub Topics

```txt
flutter dart firebase firestore firebase-auth google-sign-in textile-marketplace marketplace-app konveksi garment-app inventory-management order-management
```

---

## Author

Developed by Ira Roni Yuda.

This project was built as a Flutter prototype for textile marketplace operations, product catalogue management, customer records, order handling, stock tracking, and seller reporting.
