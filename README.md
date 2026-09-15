# Business Platform — Flutter Frontend

Cross-platform B2B management application for fitness centers and academies, featuring dedicated role-driven experiences for **Owners**, **Trainers**, and **Members**. Built with **SOLID Principles** and **Clean UI Architecture**.

## 🌐 Production Status: ✅ Connected to AWS Backend

- **Backend Target**: `http://65.2.82.25:3001`
- **Supported Platforms**: Web (`build/web/`), Android (`android/`), Desktop (Windows)
- **Integration Tests**: ✅ 100% Passing (`flutter test test/api_integration_test.dart`)

---

## 🏛️ Clean UI Architecture & SOLID Design

```
lib/
├── config/
│   └── api_config.dart                # Backend URL configuration
├── theme/
│   ├── app_colors.dart                # Professional B2B slate/indigo palette
│   ├── app_text_styles.dart           # Typography scale
│   └── app_theme.dart                 # Material 3 ThemeData definition
├── models/
│   ├── user.dart                      # Authenticated user model
│   ├── member.dart                    # Member profile model
│   ├── trainer.dart                   # Trainer profile model
│   ├── plan.dart                      # Membership plan model
│   ├── booking.dart                   # Session booking model
│   ├── kyc_record.dart                # KYC submission record
│   ├── kyc_status.dart                # KYC status enum with color badges
│   └── dashboard_stats.dart           # Owner metrics aggregation model
├── repositories/
│   ├── business_repository.dart       # Interface & implementation for business queries
│   ├── kyc_repository.dart            # Interface & implementation for KYC workflows
│   ├── plan_repository.dart           # Interface & implementation for plans
│   └── booking_repository.dart        # Interface & implementation for bookings
├── providers/
│   ├── auth_provider.dart             # JWT authentication & session lifecycle
│   └── business_dashboard_provider.dart # State coordinator for owner dashboard
├── widgets/
│   ├── b2b_stat_card.dart             # Metric card with icons & percentage indicators
│   ├── b2b_status_badge.dart          # Verified/Pending/Rejected badge pill
│   ├── b2b_data_table.dart            # Paginated & responsive tabular view
│   ├── b2b_avatar_chip.dart           # Member/Trainer avatar chip
│   ├── b2b_kyc_review_card.dart       # Expandable review card with action buttons
│   ├── b2b_empty_state.dart           # Polished empty state illustration
│   └── b2b_adaptive_shell.dart        # Adaptive responsive layout shell
└── screens/
    ├── login_screen.dart              # Multi-role authentication & registration
    ├── owner/
    │   ├── owner_dashboard.dart       # Business overview, KYC review, members & trainers
    │   └── manage_plans_screen.dart   # Plan creation & management
    ├── trainer/
    │   └── trainer_dashboard.dart     # Availability scheduling & booking tracking
    └── member/
        └── member_dashboard.dart      # KYC submission, subscription plans, bookings
```

---

## 🚀 Key Features by User Role

### 👔 Owner Experience
- **Overview Metrics**: Active Members, Active Trainers, Pending KYC Submissions, Total Revenue.
- **KYC Review Hub**: Direct approval and rejection workflow with feedback notes.
- **Tenant Management**: Real-time listing of registered staff and members with one-tap copying of `businessId`.
- **Membership Plan Management**: Form to create and configure plans with pricing, duration, and feature sets.

### 🏋️ Trainer Experience
- **Availability Management**: Date picker, start/end time pickers, and capacity limits.
- **Session Attendance**: Real-time list of booked members per training session.

### 🧑 Member Experience
- **KYC Onboarding**: Identity document upload (Aadhaar, PAN) and camera selfie integration.
- **Plan Subscriptions**: Dynamic plan catalog with Razorpay-style payment order simulation and instant verification.
- **Training Bookings**: Browse available trainer slots and book sessions with instant confirmation.

---

## 🧪 Verification & Testing

### Live Integration Tests
The frontend includes automated end-to-end integration tests connected directly to the live AWS server:

```powershell
flutter test test/api_integration_test.dart
```

**Test Coverage**:
1. Live AWS Server Health Check (`/api/health`)
2. Owner Registration & Tenant Business Creation
3. Member Registration with Tenant Binding
4. Trainer Registration & Availability Slot Creation
5. KYC Submission, Status Verification & Owner Approval
6. Plan Creation, Order Generation & Subscription Verification
7. Session Booking & Slot Capacity Validation

---

## 💻 Local Quick Start

```powershell
# 1. Fetch dependencies
flutter pub get

# 2. Run on preferred platform
flutter run -d chrome        # Web preview
flutter run -d windows       # Windows desktop preview
flutter run -d <device_id>   # Android physical device or emulator
```
