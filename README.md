# NTNC MIS — Mobile Information System

> **National Trust for Nature Conservation, Nepal**
> A Flutter mobile application for field management of Conservation Area entry permits and visitor check-ins.

---

## Overview

The NTNC MIS mobile app is a field operations tool used by checkpost officials and headquarters staff across Nepal's protected Conservation Areas. It enables real-time tracking of visitor permits and entry/exit movements at Conservation Area checkposts — replacing paper-based processes with a connected, authenticated mobile workflow.

The app serves **Nepal's Conservation Area network**, which includes projects such as the **Annapurna Conservation Area Project (ACAP)** and others managed under NTNC. Checkpost officials at entry and exit points use the app to verify permits and record visitor movements as they happen.

---

## What This System Does

### Permit Management
The app allows officials to look up any Conservation Area entry permit by its unique permit code. A permit record contains the visitor's full identity (name, passport number, date of birth, gender, nationality), the conservation project they are visiting, the issuing office that issued the permit, and the designated entry and exit checkposts for their route. Officials can instantly verify whether a permit is valid and within its travel dates.

### Check-In & Check-Out Tracking
At each checkpost, officials record when a permit holder passes through — either entering (check-in) or leaving (check-out) the Conservation Area. Each record captures the exact time and an optional remark. This creates a real-time movement log for every visitor. The system supports individual check-ins for single visitors as well as bulk processing for groups arriving together.

### Check-In History & Review
Officials can view a list of all check-ins recorded at their post, optionally filtered by date. Each record shows the permit holder's name and permit code, the direction of travel, and the time it was logged. Check-in records that were entered in error can be deleted with confirmation.

### System Notices
The headquarters can broadcast operational notices and announcements to all app users. When an active notice exists, it displays as a dismissible banner at the top of the home screen. If no notice is active, the banner is hidden automatically.

### Authentication & Role-Based Access
All field operations require secure login with a registered email and password. On successful login, the app receives and stores a JWT (JSON Web Token) which is attached to all subsequent requests. Each user account carries a role (for example, `hq` for Head Quarter staff) that determines their level of access within the MIS system. Token expiry is handled gracefully — the app redirects to the login screen if a session expires.

---

## Key Concepts

**Conservation Area** — A protected natural region in Nepal managed by NTNC. Visitors require an official entry permit to trek or travel within these areas.

**Permit** — An official document issued to a visitor, tied to a specific conservation project, with defined valid travel dates and designated entry and exit checkposts.

**Permit Code** — A unique alphanumeric identifier (e.g. `C5XXX`) printed on each permit. Officials use this code to look up permit details and record check-ins.

**Check-In / Check-Out** — A record of a permit holder passing through a checkpost, with direction (entering or leaving), timestamp, and optional remark.

**Checkpost** — A physical monitoring point at Conservation Area entry and exit locations, staffed by officials who use this app.

**Issuing Office** — The office (e.g. EP Counter, Pokhara) that issued the permit to the visitor.

---

## Features

- Secure JWT-based login with session persistence
- Permit lookup by permit code with full holder and route details
- Single and bulk check-in / check-out recording
- Date-filtered check-in history with pull-to-refresh
- Check-in deletion with confirmation
- Headquarters notice banner with session-level dismissal
- User profile display with role information
- Graceful offline and error handling throughout

---

## Project Structure

```
lib/
├── main.dart
├── models/
│   ├── user_profile.dart        # User and role models
│   ├── permit.dart              # Permit, Country, Project, Office models
│   └── check_in.dart           # CheckIn and PermitSummary models
├── services/
│   ├── api_client.dart          # Base HTTP client with header injection
│   ├── token_manager.dart       # JWT storage and retrieval
│   ├── auth_service.dart        # Login
│   ├── profile_service.dart     # User profile
│   ├── permit_service.dart      # Permit lookup
│   ├── check_in_service.dart    # Check-in CRUD and bulk operations
│   └── notice_service.dart      # System notices
├── screens/
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── profile_screen.dart
│   ├── permit_search_screen.dart
│   ├── check_in_list_screen.dart
│   ├── check_in_screen.dart
│   └── bulk_check_in_screen.dart
└── widgets/
    └── notice_banner.dart       # Reusable dismissible notice widget
```

---

## Getting Started

### Prerequisites

- Flutter SDK (stable channel)
- Dart SDK
- Android Studio / Xcode for device/emulator

### Installation

```bash
# Clone the repository
git clone https://github.com/your-org/ntnc-mis-flutter.git
cd ntnc-mis-flutter

# Install dependencies
flutter pub get

# Run on a connected device or emulator
flutter run
```

### Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0
  shared_preferences: ^2.2.0
```

---

## Authentication Flow

1. The user logs in with their registered email and password.
2. On success, the JWT access token is securely stored on the device.
3. All subsequent API calls automatically include the token as a `Bearer` header.
4. If the token expires (HTTP 401), the app clears the stored token and returns the user to the login screen.

---

## Screens & Functionality

| Screen | Purpose |
|---|---|
| Login | Authenticates the user and stores the JWT token |
| Home | Entry point; displays the notice banner if one is active |
| Profile | Shows the logged-in user's name, email, gender, status, and roles |
| Permit Search | Look up any permit by code and view full holder and route details |
| Check-In List | View all check-ins, optionally filtered by date, with pull-to-refresh |
| Single Check-In | Record one visitor's entry or exit with optional time and remark |
| Bulk Check-In | Process multiple permits at once; shows success/failure per permit |

---

## Error Handling

The app handles all standard HTTP error states:

| Code | Meaning | App Behaviour |
|---|---|---|
| 200 / 201 | Success | Normal flow, success message where applicable |
| 401 | Unauthorised | Clears token, redirects to Login |
| 403 | Forbidden | Shows access denied message |
| 404 | Not found | Shows contextual not-found message (e.g. "Permit not found") |
| 422 | Validation error | Displays field-level errors next to the relevant input |
| 500 | Server error | Shows a generic error and logs for debugging |
| Network failure | No connection | Shows a user-friendly offline message |

---

## Contributing

1. Fork the repository and create a feature branch.
2. Follow the existing service/model/screen structure.
3. Ensure all API calls go through `ApiClient` so headers are applied consistently.
4. Submit a pull request with a clear description of what was changed and why.

---

## Author and Developer
**Sanjog Godar** — Senior Flutter Developer and Project Manager
**Dipendra Gurung** — Software Engineer
National Trust for Nature Conservation, Nepal
[mis.ntnc.org.np](https://mis.ntnc.org.np)

---

## About NTNC

The **National Trust for Nature Conservation (NTNC)** is an autonomous, not-for-profit organisation established under the laws of Nepal. NTNC manages several Conservation Areas across the country, working to protect Nepal's natural heritage and biodiversity while supporting sustainable tourism and the livelihoods of local communities.

---

*This repository contains the Flutter mobile client for the NTNC MIS platform.*