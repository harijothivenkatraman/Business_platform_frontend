# Business Platform — Flutter Frontend

Cross-platform Flutter app for managing a multi-role business platform with role-driven dashboards for Owners, Trainers, and Members.

## Current Status: ✅ Built & Connected to AWS

- Web build: ✅ Compiled (`build/web/`)
- Android: ⚙️ Configured (manifests patched, permissions set)
- Backend: Live at `http://65.2.82.25:3001`
- Integration tests: ✅ 2/2 passed (health + full multi-tenant auth flow)

## Tech Stack

- **Framework**: Flutter 3.38.3 / Dart 3.8
- **State Management**: Provider
- **HTTP Client**: http package
- **Storage**: SharedPreferences (token persistence)
- **Camera**: image_picker (KYC selfie upload)
- **Formatting**: intl (date/currency formatting)

## Screens & Features

### 🔐 Login / Register Screen
- Email and password input fields with validation
- **Login / Register toggle** — switch between modes
- **Role selector dropdown** (Owner, Trainer, Member) in register mode
- **Business ID field** — required for Trainer/Member registration (paste from Owner)
- Loading spinner during API calls
- Error snackbars for failed auth

### 👔 Owner Dashboard
- **Business ID banner** in AppBar — copy and share with staff
- **4 stat cards**: Total Members, Total Trainers, Pending KYC, Revenue
- **KYC review section** — list of pending submissions with:
  - Document details (Aadhaar, PAN)
  - **Approve / Reject buttons** per submission
- **Members list** — name, email, KYC status chip (green/orange/red)
- **Trainers list** — name, email
- **Pull-to-refresh** to reload all data

### 📋 Manage Plans Screen (Owner)
- **Plans list** — cards showing plan name, price (₹), duration (days), features
- **Floating Action Button** → opens Create Plan dialog
- **Create Plan form**: name, price, duration, features (comma-separated)
- Empty state with prompt to create first plan

### 🏋️ Trainer Dashboard
- **Booked sessions list** — member name, date, time slot
- **Set Availability button** → opens dialog with:
  - Date picker
  - Start time / End time pickers
  - Capacity input
- Empty state when no sessions booked

### 🧑 Member Dashboard
- **KYC Status card** — color-coded: green (verified), orange (pending), red (rejected)
- **Submit KYC button** → form with:
  - Aadhaar number field
  - PAN number field
  - Selfie upload via camera (image_picker)
- **Active subscription card** — plan name, expiry date, status
- **Browse Plans section** — available plans with **Subscribe** button
- **Subscription flow**: Create order → simulate payment → verify signature
- **My Bookings list** — upcoming sessions with **Cancel** button
- **Book Session flow**: Select trainer → pick time slot → confirm booking

### 🏠 Home Shell (main.dart)
- **Role-based navigation** using BottomNavigationBar + IndexedStack
  - Owner: Dashboard tab + Plans tab
  - Trainer: Dashboard tab
  - Member: Dashboard tab
- **Logout button** in AppBar — clears token, returns to login

## Quick Start

```bash
flutter pub get
flutter run -d chrome        # Web
flutter run -d android       # Android (device/emulator)
```

## Project Structure

```
lib/
├── main.dart                          # App entry, role-based navigation
├── config/
│   └── api_config.dart                # Backend URL (65.2.82.25:3001)
├── services/
│   └── api_service.dart               # HTTP client (GET/POST/PUT/DELETE)
├── providers/
│   └── auth_provider.dart             # Auth state, login/register/logout
└── screens/
    ├── login_screen.dart              # Login + Register with role selection
    ├── owner/
    │   ├── owner_dashboard.dart       # Stats, KYC review, members, trainers
    │   └── manage_plans_screen.dart   # Plan CRUD
    ├── trainer/
    │   └── trainer_dashboard.dart     # Sessions, availability
    └── member/
        └── member_dashboard.dart      # KYC, subscriptions, bookings
```
