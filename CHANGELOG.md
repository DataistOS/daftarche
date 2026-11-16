# Changelog

## [0.4.0] - 2026-11-16

### Added
- **Backend Integration:** Successfully connected and synchronized the app with the Hodhod backend `daftarche` collection.
- **Environment Config:** Added `.env` support using `flutter_dotenv` for dynamic `API_URL` management.
- **Statistics Dashboard:** Integrated live stats for total contacts, favorites, and recorded interactions.
- **UI Enhancements:**
  - Global Dark Mode switcher using `ValueNotifier`.
  - Digital business card (vCard) generation and QR code sharing modal (`qr_flutter`).
  - Interaction history tracking per contact.

### Changed
- **Data Handling:** Refactored `ContactModel` and services to use comma-separated plain string storage matching backend schema.
- **Form Validation:** Improved form state management and robust group validation in `ContactFormSheet`.
- **Flutter Modernization:** Replaced all deprecated `withOpacity` methods with `.withValues(alpha:)` to prevent precision loss.

### Fixed
- Resolved 400/404 API request errors by aligning frontend payloads with backend text schemas.
- Fixed `TypeError`, `AssertionError`, and null-check crashes during contact creation, editing, and card rendering.
- Fixed `DropdownButtonFormField` crash caused by dynamic or unlisted group values during initialization.

## [0.3.0] - 2026-11-14

### Added
* **Typography & Styling:** Integrated local Vazirmatn font assets to provide high-quality, professional Persian typography.
* **RTL & Localization:** Added full Right-to-Left (RTL) layout support and global Material/Widgets localization delegates (`fa_IR`).
* **Digital Business Card:** Implemented vCard generation and QR code sharing (`qr_flutter`) in contact detail views.
* **UI Components:** Added modular widgets including `ContactCard`, `ContactFormSheet`, and enriched `ContactDetailScreen`.

### Changed
* **Contact Screens:** Refactored `ContactsListScreen` and `ContactsScreen` for smooth group filtering, fast searching, and favorite toggling.
* **Services & Models:** Updated `ContactService` and contact data models to handle robust backend data synchronization securely.

### Fixed
* Resolved strict null-safety and list iterator exceptions (`Bad state: No element`) across UI item builders.
* Fixed package dependency configurations in `pubspec.yaml` for stable offline and local asset mapping.

## [0.1.1] - 2026-11-09

### Refactor
- Modularized project architecture by introducing dedicated layers:
    - Added `ContactService` in `lib/services/` for managing Upupa SDK backend calls.
    - Moved `ContactsScreen` to `lib/screens/` for cleaner UI management.
- Streamlined `main.dart` to focus solely on app initialization and global theme configuration.

## [0.1.0] - 2026-11-08

### Added
- Initial project structure for **Daftarche** (Contact Management Application).
- Integrated local `upupa_dart` dependency and configured `pubspec.yaml`.
- Implemented `ContactsScreen` with Upupa SDK integration supporting fetching, adding, and deleting contacts.
- Added standard Flutter `.gitignore` and project metadata files.