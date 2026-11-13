# 🏠 FindBookStay

**FindBookStay** is a production-ready Flutter mobile application — a one-stop marketplace for **renting apartments & bachelor seats**, **booking hotel stays & getaways**, **reserving sports turfs**, and **buying verified properties**.

> Built with Flutter · Dart 3 · Material UI · Google Fonts (Plus Jakarta Sans)

---

## ✨ Features

### 🔐 Authentication Suite
- **Role-First Registration** — 2-step flow: choose Tenant/Guest/Player or Host/Landlord/Turf Owner, then fill the form
- **Sign In** — Email & password with real-time validation and error badges
- **Forgot Password** — Email or phone number recovery flow
- **OTP Verification** — 6-digit squircle input boxes with auto-advance and 45s resend countdown
- **Reset Password** — New password with real-time strength meter and confirm match indicator
- **Terms & Privacy Modals** — Tappable inline links open polished bottom-sheet modals with full content
- **Dynamic Bottom Navigation** — 5-tab navigation shell (Explore, Saved, Bookings, Inbox, Profile/Account) that reacts dynamically to Signed-In vs Guest (Non-Signed-In) user states

### 🎨 UI / UX
- **Splash Screen** — Facebook-style branded splash with logo & animated tagline
- **Onboarding** — 4-step swipeable slides: `01 RENT → 02 BOOK → 03 SPORTS → 04 BUY`
- **Home Screen** — Category grid: Rent, Book, Sports, Buy
- **Deep Forest Green** design system with Mint accent
- Smooth page transitions, haptic feedback, animated role cards, password eye toggle

### 🛠 Code Quality
- Null-safe Dart 3, Flutter best practices
- `flutter analyze` — zero issues
- 7 widget tests — all passing
- Reusable custom widgets: `CustomAuthInput`, `CustomAuthButton`, `RoleSelectionCard`, `PasswordStrengthMeter`, `OtpDigitInput`

---

## 📱 Screens

| Screen | Description |
|--------|-------------|
| `SplashScreen` | Branded 2.1s splash with logo |
| `OnboardingScreen` | 4-slide swipeable intro (skippable) |
| `HomeScreen` | 5-Tab dynamic navigation shell (Explore, Saved, Bookings, Inbox, Profile/Account) |
| `SignInScreen` | Login with email & password |
| `RegisterRoleScreen` | Step 1 — Choose Tenant or Host role |
| `RegisterFormScreen` | Step 2 — Full registration form with Terms modal |
| `ForgotPasswordScreen` | Account recovery via registered email address |
| `OtpVerificationScreen` | 6-digit code entry with countdown timer |
| `ResetPasswordScreen` | New password with success confirmation dialog |

---

## 🎨 Design System

| Token | Value |
|-------|-------|
| Primary | `#073B35` Deep Forest Green |
| Primary Dark | `#052F2A` |
| Accent / Mint | `#10B981` |
| Background | `#FFFFFF` / `#F8FAF9` |
| Text Primary | `#172B2A` |
| Text Secondary | `#64748B` |
| Border | `#E2EAE6` |
| Error | `#DC2626` |
| Font | Plus Jakarta Sans (Google Fonts) |

---

## 🗂 Project Structure

```
lib/
├── main.dart                        # App entry point → SplashScreen
├── core/
│   ├── services/
│   │   └── auth_service.dart        # Reactive auth state (Signed-In vs Guest)
│   └── theme/
│       └── app_colors.dart          # Full color palette & gradients
├── models/
│   └── onboarding_item.dart         # Onboarding slide data model
└── screens/
    ├── splash/
    │   └── splash_screen.dart
    ├── onboarding/
    │   ├── onboarding_screen.dart
    │   └── widgets/
    │       ├── animated_page_indicator.dart
    │       ├── onboarding_illustration_card.dart
    │       └── onboarding_slide_widget.dart
    ├── common/
    │   └── legal_modal_sheet.dart   # Shared Terms & Privacy bottom modals
    ├── home/
    │   ├── home_screen.dart         # 5-Tab dynamic bottom navigation shell
    │   ├── tabs/
    │   │   ├── explore_tab.dart     # Marketplace discovery & search
    │   │   ├── saved_tab.dart       # Wishlist (active vs guest auth gate)
    │   │   ├── bookings_tab.dart    # My stays & turf slots (active vs guest)
    │   │   ├── inbox_tab.dart       # Landlord/turf chats (active vs guest)
    │   │   └── profile_tab.dart     # Account profile & sign-out vs Join hero
    │   └── widgets/
    │       └── guest_auth_gate_card.dart # Reusable guest auth gate prompt
    └── auth/
        ├── sign_in_screen.dart
        ├── register_role_screen.dart
        ├── register_form_screen.dart  # Includes Terms & Privacy modals
        ├── forgot_password_screen.dart
        ├── otp_verification_screen.dart
        ├── reset_password_screen.dart
        └── widgets/
            ├── custom_auth_input.dart      # 52px input with animated error badge
            ├── custom_auth_button.dart     # 54px CTA with loading spinner & haptics
            ├── password_strength_meter.dart
            ├── role_selection_card.dart    # Animated press + slide arrow
            └── otp_digit_input.dart       # Auto-advance squircle digit box
```

---

## 📦 Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `material_ui` | `^1.1.0` | Flutter Material Design components |
| `google_fonts` | `^6.2.1` | Plus Jakarta Sans typography |
| `shared_preferences` | `^2.3.2` | Persist onboarding completion state |
| `cupertino_icons` | `^1.0.8` | iOS-style icons |
| `flutter_lints` | `^6.0.0` | Dart/Flutter lint rules (dev) |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `>=3.14.0`
- Dart SDK `>=3.14.0`
- Android Studio / VS Code
- A connected device or emulator

### Installation

```bash
# Clone the repository
git clone https://github.com/your-org/findbookstay_mobile.git
cd findbookstay_mobile

# Install dependencies
flutter pub get

# Run on a connected device
flutter run

# Run on a specific device
flutter run -d <device-id>

# List available devices
flutter devices
```

### Build

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# iOS (macOS only)
flutter build ios

# Web
flutter build web
```

### Tests

```bash
# Run all tests
flutter test

# Analyze code (must show: No issues found!)
flutter analyze
```

---

## 🧪 Test Coverage

| Test | Description |
|------|-------------|
| `App starts with SplashScreen` | Logo and tagline visible on launch |
| `Onboarding slide sequence` | RENT → BOOK → SPORTS → BUY order |
| `Role Selection` | Tenant and Host cards selectable |
| `Register Form validation` | Required fields + terms checkbox |
| `Forgot Password + OTP flow` | Navigation and email display |
| `Reset Password match indicator` | Real-time password confirmation |
| `Dynamic Bottom Navigation` | Seamless Guest & Signed-in state transitions |

---

## 🔧 Platform Support

| Platform | Status |
|----------|--------|
| Android | ✅ Supported |
| iOS | ✅ Supported |
| Web | ✅ Supported |
| Windows | ✅ Supported |
| macOS | ✅ Supported |
| Linux | ✅ Supported |

---

## 📄 License

This project is licensed under the terms described in the [LICENSE](LICENSE) file.  
© 2026 FindBookStay. All rights reserved.
