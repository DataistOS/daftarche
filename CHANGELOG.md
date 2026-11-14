# Changelog

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